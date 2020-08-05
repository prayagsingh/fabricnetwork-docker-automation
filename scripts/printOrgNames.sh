#!/bin/bash
# Taking Inputs from .env file
set -a
[ -f .env ] && . .env
set +a



for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
	ORG_NAME="ORGANIZATION${ORG}_NAME"
	echo "### Value of ORGANIZATION${ORG}_NAME is: ${!ORG_NAME}"
done