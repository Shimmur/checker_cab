#!/bin/bash

# ------------------------------------------------------------------------------
# Simple script to make sure our dependencies are up and running before we
# attempt to run our tests. Used inside the test Docker container.
# ------------------------------------------------------------------------------

echo "***"
echo "Waiting for dependencies"
echo "***"

die() {
	echo $* >&2
	exit 1
}

wait_for_service() {
	# Validate input params
	PORT=$1
	HOST=$2
	SERVICE=$3
	DOCKER_NAME=$4
	test -z $PORT && die "no port passed to wait_for_service()"
	test -z $HOST && die "no host passed to wait_for_service()"
	test -z $SERVICE && die "no service name passed to wait_for_service()"
	test -z $DOCKER_NAME && die "no container name passed to wait_for_service()"

	# Start the actual dependency
	docker-compose -f ci/docker-compose.yml up -d $DOCKER_NAME || die "Can't start $SERVICE"

	# Poll the TCP socket until we see a listener up and running
	counter=0
	while ! exec 6<>/dev/tcp/$HOST/$PORT; do
	    echo "Trying to connect to $SERVICE localhost"

		counter=`expr $counter + 1`
		if [[ $counter -gt 10 ]]; then
			# Failure, abort
			die "Too many retries waiting on $SERVICE port $PORT. Exiting."
		fi

	    sleep 2
	    echo "Retrying"
	done

	echo "wait_for_service completed for $SERVICE"
}

# Services we need to have up and running before continuing with the build
# wait_for_service 8080 localhost "httpbin" httpbin

echo "***"
echo "Dependencies all started"
echo "***"
