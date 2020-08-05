#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your test network (TYFN) end-to-end test"
echo

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

# Reading custom env from .env files
set -a
[ -f .env ] && . .env
set +a

echo "### Value of CHANNEL_NAME is: $CHANNEL_NAME"
echo "### Value of DELAY is: $DELAY"
echo "### Value of MAX_RETRY is: $MAX_RETRY"
echo "### Value of VERBOSE is: $VERBOSE"
echo "### Value of DOMAIN_OF_ORDERER_ORGANIZATION is: $DOMAIN_OF_ORDERER_ORGANIZATION"
./scripts/printOrgNames.sh


# import utils
. scripts/envVar.sh

echo 
echo "### After import Orgs name :-"
./scripts/printOrgNames.sh

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
	
fi

id=$(eval id -u)
sudo chown $id:${id} -R channel-artifacts

createChannelTx() {

	set -x
	configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	res=$?
	set +x
	if [ $res -ne 0 ]; then
		echo "Failed to generate channel configuration transaction..."
		exit 1
	fi
	echo

}

createAncorPeerTx() {
	
	for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
		orgmsp="ORGANIZATION${ORG}_NAME"
		echo "#######    Generating anchor peer update for ${!orgmsp}  ##########"
		set -x
		configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${!orgmsp}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg ${!orgmsp}
		res=$?
		set +x
		if [ $res -ne 0 ]; then
			echo "Failed to generate anchor peer update for ${!orgmsp}..."
			exit 1
		fi
		echo
	done
}

createChannel() {
	setGlobals 1 1

	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		peer channel create -o orderer1.$DOMAIN_OF_ORDERER_ORGANIZATION:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer1.$DOMAIN_OF_ORDERER_ORGANIZATION -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
		set +x

		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}


# queryCommitted ORG
joinChannel() {
	echo 
	echo "===================== JOINING CHANNEL ====================="
	for org in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
		for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do	
			joinChannelRetry $peer $org	
		done
	done		
}

updateAnchorPeers() {
	PEER=$1  #<--- always 1
	ORG=$2   #<-- based on the number of orgs
	setGlobals $PEER $ORG
	changeOrg $ORG

	set -x
	peer channel update -o orderer1.$DOMAIN_OF_ORDERER_ORGANIZATION:7050 --ordererTLSHostnameOverride orderer1.$DOMAIN_OF_ORDERER_ORGANIZATION -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
	res=$?
	set +x
  
	cat log.txt
	verifyResult $res "Anchor peer update failed"
	echo "===================== Anchor peers updated for org: '$ORG' on channel '$CHANNEL_NAME' ===================== "
	sleep $DELAY
	echo
}

verifyResult() {
  if [ $1 -ne 1 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

FABRIC_CFG_PATH=${PWD}
echo "####### value of FABRIC_CFG_PATH when creating geneseis block is: $FABRIC_CFG_PATH"
## Create channeltx
echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
createChannelTx

## Create anchorpeertx
echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
createAncorPeerTx

FABRIC_CFG_PATH=$PWD/config/
echo "####### value of FABRIC_CFG_PATH when creating channel: $FABRIC_CFG_PATH"
exit 1
## Create channel
echo "Creating channel "$CHANNEL_NAME
createChannel

## Join all the peers to the channel
joinChannel 
#echo "Join Org2 peers to the channel..."
#joinChannel 0 2

## Set the anchor peers for each org in the channel
for org in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
	
	echo "Updating anchor peers for org${org}..."
	updateAnchorPeers 1 $org

done

echo
echo "========= Channel successfully joined =========== "
echo

exit 0
