#!/bin/sh -e

# ------------------------------------------------------------------------------
# Script run as the CMD for the build container
# ------------------------------------------------------------------------------

# Source the creds we passed into the container
source ./ci/creds

# Run the tests
export MIX_ENV=test
make code-check

if [ -z "$COVERALLS_REPO_TOKEN" ]; then
	echo "MISSING!!! COVERALLS_REPO_TOKEN is not set, can't report coverage!!!"
	mix test
else
	./ci/scripts/cover.sh
fi
