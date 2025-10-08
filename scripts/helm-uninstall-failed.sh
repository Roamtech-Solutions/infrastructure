#! /bin/sh

sg=$1
if [ -n "${sg}" ]; then
	helm list -n ${sg} | grep failed | cut -f 1 | xargs helm uninstall -n ${sg}
else 
	helm list | grep failed | cut -f 1 | xargs helm uninstall
fi

