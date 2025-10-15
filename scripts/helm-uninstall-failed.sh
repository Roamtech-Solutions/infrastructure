#! /bin/sh

sg=$1
if [ -z "${sg}" ]; then
	echo "Service group not provided."
	echo "Provide a service group to uninstall failed services from."
	echo "Otherwise, use 'all', to remove all of the failed services in the environment."
	exit 1
fi

# List failed services
test "${sg}" = "all" && ns_args="" || ns_args="-n ${sg}"
failed_services=$(helm list ${ns_args} | grep failed | cut -f 1)

# Uninstall failed services
test -n "${failed_services}" \
	&& echo ${failed_services} | xargs helm uninstall ${ns_args} \
	|| echo "No failed services in the '${sg}' service group to uninstall"

