#! /bin/sh

sg=$1
if [ -z "${sg}" ]; then
	echo "Service group not provided."
	echo "Provide a service group to uninstall failed services from."
	echo "Otherwise, use 'all', to remove all of the failed services in the environment."
fi

test "${sg}" = "all" && ns_args="" || ns_args="-n ${sg}"
helm list ${ns_args} | grep failed | cut -f 1 | xargs helm uninstall ${ns_args}

