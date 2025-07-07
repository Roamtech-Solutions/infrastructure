#! /bin/sh

for release in $(helm list --all-namespaces --no-headers | awk '{ print $1":"$2 }'); do
	name=$(echo ${release} | cut -d ':' -f 1)
	namespace=$(echo ${release} | cut -d ':' -f 2)
	echo "$name -> ${namespace}"
done

