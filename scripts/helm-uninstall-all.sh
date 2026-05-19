#! /bin/sh
# =========================================================================== #
if [ -z "${EXCLUDE}" ]; then
	EXCLUDE="none"
fi
service_groups=$( \
	cat terraform/vars/management/core.tfvars \
	| sed -n '/service_groups = \[/,/\]/p' \
	| grep -v 'service_groups' \
	| grep -v '[]]' \
	| tr -d '",' \
	| tr -d ' ' \
	| grep -vE "${EXCLUDE}"
)
echo "Uninstalling: ${service_groups}"

for sg in ${service_groups}; do
	echo "=== ${sg} ==="
	services=$(helm ls --short -n ${sg})

	test -n "${services}" \
	&& helm uninstall -n ${sg} $(helm ls --short -n ${sg}) \
	|| echo "No services to uninstall"

done

