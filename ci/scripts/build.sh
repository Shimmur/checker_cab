#!/bin/bash

die() {
	echo $* >&2
	exit 1
}

banner() {
	echo
	echo "*** $* ***"
	echo
}

# Store creds we need in the build container
./ci/scripts/pass-creds.sh || die "Can't pass credentials"

# Wait on deps to start
./ci/scripts/start-deps.sh || die "Can't start dependencies"

banner "Building tests"

# Run the tests and clean up
docker-compose -f ci/docker-compose.yml build tests
EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
	banner "Running tests"
	docker-compose -f ci/docker-compose.yml run tests
	EXIT_CODE=$?
	echo "Exited with exit code '${EXIT_CODE}'"
fi

test $EXIT_CODE -eq 0 || banner "FAILED"

banner "Cleaning up..."
docker-compose -f ci/docker-compose.yml down

# Make sure we fail if the tests run failed
exit $EXIT_CODE
