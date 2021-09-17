#!/bin/sh

# ------------------------------------------------------------------------------
# Pass through credentials we need in the build container
# ------------------------------------------------------------------------------

# Space separated list of vars to pass through to the build
EXPORTED_FIELDS="COVERALLS_REPO_TOKEN HEXPM_KEY"

truncate -s0 ./ci/creds
for field_name in $EXPORTED_FIELDS; do
	varname="$`echo $field_name`"
	eval value=$varname
	echo "export $field_name=$value" >> ./ci/creds
done
