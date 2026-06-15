#! /bin/sh
# ============================================================================ #
# NAME
#   ./scripts/post-deploy-verification.sh
#
# SYNOPSIS
#   ./scripts/post-deploy-verification.sh --service NAME --health-url URL [OPTIONS]
#
# DESCRIPTION
#   Run post-deploy verification checks for one deployment target:
#   1) Health endpoint check (required)
#   2) Optional business endpoint check
#   3) Optional DB connectivity check
#   4) Optional queue connectivity check
#
#   By default, strict target validation is enabled. This means the script
#   verifies that the URL looks like it belongs to the provided service name.
#
#   Practical test model:
#   - Health check: validates service is reachable and returns 2xx.
#   - Queue check: validates queue endpoint is reachable (TCP) or probe command works.
#   - Database check: validates DB endpoint is reachable (TCP) or probe command works.
#   - Business check: validates a lightweight business endpoint (for example /v1/ping).
#
# EXAMPLES
#   # 1) Health verification only
#   ./scripts/post-deploy-verification.sh \
#     --service emalify-biz \
#     --health-url https://biz.emalify.com/health
#
#   # 2) Health + business endpoint verification
#   ./scripts/post-deploy-verification.sh \
#     --service emalify-sms-inbox \
#     --health-url https://sms-inbox.emalify.com/health \
#     --business-url https://sms-inbox.emalify.com/v1/ping
#
#   # 3) Health + DB + queue using host/port checks
#   ./scripts/post-deploy-verification.sh \
#     --service paykit-api \
#     --health-url https://api.paykit.com/healthz \
#     --db-host 10.50.1.23 --db-port 3306 \
#     --queue-host rabbitmq.paykit.svc.cluster.local --queue-port 5672
#
#   # 4) Health + DB + queue using custom in-cluster probe commands
#   ./scripts/post-deploy-verification.sh \
#     --service paykit-api \
#     --health-url https://api.paykit.com/healthz \
#     --db-cmd "kubectl -n paykit exec deploy/paykit-api -- /app/bin/db-probe" \
#     --queue-cmd "kubectl -n paykit exec deploy/paykit-api -- /app/bin/queue-probe"
# ============================================================================ #

set -u

SCRIPT_NAME=$(basename "$0")

SERVICE_NAME=""
ENVIRONMENT="${ENV:-development}"
HEALTH_URL=""
BUSINESS_URL=""
DB_HOST=""
DB_PORT=""
QUEUE_HOST=""
QUEUE_PORT=""
DB_CMD=""
QUEUE_CMD=""
HTTP_TIMEOUT="10"
RETRIES="3"
RETRY_DELAY="3"
VERBOSE="0"
STRICT_TARGET_MATCH="1"
EXPECTED_HOST=""

PASS_COUNT=0
FAIL_COUNT=0

usage() {
  cat <<EOF
Usage:
  ${SCRIPT_NAME} --service NAME --health-url URL [options]

Required:
  --service NAME              Service identifier (for logs)
  --health-url URL            Health endpoint URL

Optional:
  --env ENV                   Environment label (default: ${ENVIRONMENT})
  --business-url URL          Business endpoint URL to ping
  --db-host HOST              DB host for TCP check (requires --db-port)
  --db-port PORT              DB port for TCP check
  --queue-host HOST           Queue host for TCP check (requires --queue-port)
  --queue-port PORT           Queue port for TCP check
  --db-cmd CMD                Custom DB check command (overrides db host/port)
  --queue-cmd CMD             Custom queue check command (overrides queue host/port)
  --http-timeout SECONDS      Curl timeout per request (default: ${HTTP_TIMEOUT})
  --retries N                 Retries per check (default: ${RETRIES})
  --retry-delay SECONDS       Delay between retries (default: ${RETRY_DELAY})
  --expected-host HOST        Require URL host to match this exact host
  --no-strict-target-match    Disable service-to-URL matching guard
  --verbose                   Print more details
  --help                      Show this help

Notes:
  - HTTP checks pass on any 2xx status code.
  - For TCP checks, this script uses nc (netcat).
  - Strict target match is ON by default to prevent checking the wrong service URL.
  - Prefer --expected-host in production to avoid checking the wrong endpoint.

Recommended post-deploy usage:
  1) Run health check first.
  2) Add business endpoint check to validate key application behavior.
  3) Add DB and queue checks for dependency readiness.
  4) Keep retries low in CI for fast feedback and clear failures.
EOF
}

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $*"
}

verbose_log() {
  if [ "${VERBOSE}" = "1" ]; then
    log "$*"
  fi
}

mark_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  echo "PASS: $1"
}

mark_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  echo "FAIL: $1"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"
    exit 1
  fi
}

validate_number() {
  value="$1"
  field_name="$2"
  case "${value}" in
    ''|*[!0-9]*)
      echo "Invalid ${field_name}: ${value}"
      exit 1
      ;;
  esac
}

lowercase() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

extract_host() {
  # Strips scheme, path, and port from URL.
  printf '%s' "$1" | sed -E 's#^[a-zA-Z][a-zA-Z0-9+.-]*://##; s#/.*$##; s/:.*$//'
}

service_suffix() {
  # For service group naming like emalify-sms-inbox, use the suffix sms-inbox.
  # If no dash exists, use whole service name.
  svc="$1"
  suffix=$(printf '%s' "${svc}" | cut -d '-' -f 2-)
  if [ "${suffix}" = "${svc}" ]; then
    printf '%s' "${svc}"
  else
    printf '%s' "${suffix}"
  fi
}

validate_target_alignment() {
  url="$1"
  host=$(extract_host "${url}")
  host_lc=$(lowercase "${host}")
  url_lc=$(lowercase "${url}")

  if [ -n "${EXPECTED_HOST}" ]; then
    expected_lc=$(lowercase "${EXPECTED_HOST}")
    if [ "${host_lc}" != "${expected_lc}" ]; then
      echo "Target validation failed: URL host '${host}' does not match expected host '${EXPECTED_HOST}'"
      return 1
    fi
    return 0
  fi

  if [ "${STRICT_TARGET_MATCH}" != "1" ]; then
    return 0
  fi

  suffix=$(service_suffix "${SERVICE_NAME}")
  matched=0

  # Split suffix on common separators and require one meaningful token match.
  for token in $(printf '%s' "${suffix}" | tr '._-' '   '); do
    # Skip tiny tokens that cause noisy matches.
    if [ "${#token}" -lt 3 ]; then
      continue
    fi
    token_lc=$(lowercase "${token}")
    if printf '%s' "${url_lc}" | grep -q "${token_lc}"; then
      matched=1
      break
    fi
  done

  if [ "${matched}" -ne 1 ]; then
    echo "Target validation failed: URL '${url}' does not appear to match service '${SERVICE_NAME}'"
    echo "Hint: use --expected-host HOST for strict host matching, or --no-strict-target-match to bypass this guard."
    return 1
  fi

  return 0
}

run_with_retries() {
  check_name="$1"
  check_cmd="$2"

  attempt=1
  while [ "${attempt}" -le "${RETRIES}" ]; do
    verbose_log "${check_name}: attempt ${attempt}/${RETRIES}"
    if sh -c "${check_cmd}" >/dev/null 2>&1; then
      mark_pass "${check_name}"
      return 0
    fi

    if [ "${attempt}" -lt "${RETRIES}" ]; then
      verbose_log "${check_name}: failed, retrying in ${RETRY_DELAY}s"
      sleep "${RETRY_DELAY}"
    fi
    attempt=$((attempt + 1))
  done

  mark_fail "${check_name}"
  return 1
}

http_check_cmd() {
  # shellcheck disable=SC2016
  echo "status=\$(curl -sS -o /dev/null -w '%{http_code}' --max-time ${HTTP_TIMEOUT} '${1}' || echo 000); case \"\${status}\" in 2*) exit 0;; *) exit 1;; esac"
}

tcp_check_cmd() {
  host="$1"
  port="$2"
  echo "nc -z '${host}' '${port}'"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --service)
      SERVICE_NAME="$2"
      shift 2
      ;;
    --env)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --health-url)
      HEALTH_URL="$2"
      shift 2
      ;;
    --business-url)
      BUSINESS_URL="$2"
      shift 2
      ;;
    --db-host)
      DB_HOST="$2"
      shift 2
      ;;
    --db-port)
      DB_PORT="$2"
      shift 2
      ;;
    --queue-host)
      QUEUE_HOST="$2"
      shift 2
      ;;
    --queue-port)
      QUEUE_PORT="$2"
      shift 2
      ;;
    --db-cmd)
      DB_CMD="$2"
      shift 2
      ;;
    --queue-cmd)
      QUEUE_CMD="$2"
      shift 2
      ;;
    --http-timeout)
      HTTP_TIMEOUT="$2"
      shift 2
      ;;
    --retries)
      RETRIES="$2"
      shift 2
      ;;
    --retry-delay)
      RETRY_DELAY="$2"
      shift 2
      ;;
    --expected-host)
      EXPECTED_HOST="$2"
      shift 2
      ;;
    --no-strict-target-match)
      STRICT_TARGET_MATCH="0"
      shift
      ;;
    --verbose)
      VERBOSE="1"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [ -z "${SERVICE_NAME}" ]; then
  echo "Missing required argument: --service"
  usage
  exit 1
fi

if [ -z "${HEALTH_URL}" ]; then
  echo "Missing required argument: --health-url"
  usage
  exit 1
fi

validate_number "${HTTP_TIMEOUT}" "--http-timeout"
validate_number "${RETRIES}" "--retries"
validate_number "${RETRY_DELAY}" "--retry-delay"

if [ -n "${DB_HOST}" ] && [ -z "${DB_PORT}" ]; then
  echo "--db-port is required when --db-host is provided"
  exit 1
fi

if [ -n "${DB_PORT}" ]; then
  validate_number "${DB_PORT}" "--db-port"
fi

if [ -n "${QUEUE_HOST}" ] && [ -z "${QUEUE_PORT}" ]; then
  echo "--queue-port is required when --queue-host is provided"
  exit 1
fi

if [ -n "${QUEUE_PORT}" ]; then
  validate_number "${QUEUE_PORT}" "--queue-port"
fi

require_command curl

if [ -n "${DB_HOST}${QUEUE_HOST}" ] && [ -z "${DB_CMD}${QUEUE_CMD}" ]; then
  require_command nc
fi

if ! validate_target_alignment "${HEALTH_URL}"; then
  exit 1
fi

if [ -n "${BUSINESS_URL}" ]; then
  if ! validate_target_alignment "${BUSINESS_URL}"; then
    exit 1
  fi
fi

log "Running post-deploy verification checks"
log "Service: ${SERVICE_NAME}"
log "Environment: ${ENVIRONMENT}"

run_with_retries "Health endpoint (${HEALTH_URL})" "$(http_check_cmd "${HEALTH_URL}")" || true

if [ -n "${BUSINESS_URL}" ]; then
  run_with_retries "Business ping (${BUSINESS_URL})" "$(http_check_cmd "${BUSINESS_URL}")" || true
fi

if [ -n "${DB_CMD}" ]; then
  run_with_retries "DB connectivity (custom command)" "${DB_CMD}" || true
elif [ -n "${DB_HOST}" ] && [ -n "${DB_PORT}" ]; then
  run_with_retries "DB connectivity (${DB_HOST}:${DB_PORT})" "$(tcp_check_cmd "${DB_HOST}" "${DB_PORT}")" || true
fi

if [ -n "${QUEUE_CMD}" ]; then
  run_with_retries "Queue connectivity (custom command)" "${QUEUE_CMD}" || true
elif [ -n "${QUEUE_HOST}" ] && [ -n "${QUEUE_PORT}" ]; then
  run_with_retries "Queue connectivity (${QUEUE_HOST}:${QUEUE_PORT})" "$(tcp_check_cmd "${QUEUE_HOST}" "${QUEUE_PORT}")" || true
fi

echo ""
echo "Verification summary: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"

if [ "${FAIL_COUNT}" -gt 0 ]; then
  exit 1
fi

exit 0
