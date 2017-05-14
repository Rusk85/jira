#!/bin/bash
# Run Jira tailored for my home network muncic.local
# Variable 'IMAGE_NAME' sourced from 'CONTAINER_NAME_FILE'

# DEBUG
#set -euxo pipefail
# RELEASE
set -eu
set -o errexit    # abort script at first error
set -o pipefail   # return the exit status of the last command in the pipe
set -o nounset    # treat unset variables and parameters as an error

HOST_PORT=8585
PROXY_NAME="cla-airsoft.duckdns.org"
PROXY_PORT=80
PROXY_SCHEME="http"
JIRA_CONTEXT="jira"
CONTAINER_NAME="jira"
CUR_DIR=$(pwd)
CONTAINER_NAME_FILE="container.cfg"

# Resource Limitations
MEM_SIZE="1024m" # The maximum amount of memory the container can use
MEM_SWAP_RATIO="40" 
MEM_SWAP="8192m" # The amount of memory this container is allowed to swap to disk

source $CUR_DIR/$CONTAINER_NAME_FILE

check_container()
{
	local guid=$1
	printf "\n\n"
	docker container ls --filter id=$guid
}

printf "\nRunning image $IMAGE_NAME on host port $HOST_PORT.\n"
printf "\nInstance $CONTAINER_NAME will be reachable on http://$PROXY_NAME.\n"
printf "\nInstance is limited to $MEM_SIZE memory and is allowed to swap up to $MEM_SWAP\n"

RESULT=$(docker run -d --name ${CONTAINER_NAME} \
	--link mysqlv5-6:mysql \
	--memory=${MEM_SIZE} \
	--memory-swappiness=${MEM_SWAP_RATIO} \
	--memory-swap=${MEM_SWAP} \
	-p ${HOST_PORT}:8080 \
	-e JIRA_PROXY_NAME=${PROXY_NAME} \
	-e JIRA_PROXY_PORT=${PROXY_PORT} \
	-e JIRA_PROXY_SCHEME=${PROXY_SCHEME} \
	-e JIRA_CONTEXT_PATH=${JIRA_CONTEXT} \
	$IMAGE_NAME)

if [ "$?" -eq "0" ] ; then
	printf "\nInstance $RESULT is running successfully.\n"
else
	printf "\nRunning instance $RESULT failed with error code $?\n"
fi
check_container $RESULT

