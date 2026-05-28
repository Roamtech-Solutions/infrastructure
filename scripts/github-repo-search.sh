#! /bin/sh

. scripts/common.sh

gh repo list \
	Roamtech-Solutions \
	--limit 500 \
	--jq ".[] | select(.name | startswith(\"${1}-\")) | .name" \
	--json name

