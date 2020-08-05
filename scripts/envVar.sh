#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts
set -a
[ -f .env ] && . .env
set +a

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer1.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/tlscacerts/tlsca.$DOMAIN_OF_ORDERER_ORGANIZATION-cert.pem
for org in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
    echo 
    echo "## Setting Path to TLSCA for Org$org"
    ORG_DOMAIN="DOMAIN_OF_ORGANIZATION${org}"
    export PEER1_ORG${org}_CA=${PWD}/crypto-config/peerOrganizations/${!ORG_DOMAIN}/peers/peer1.${!ORG_DOMAIN}/tls/ca.crt
    ROOTCERT="PEER1_ORG${org}_CA"
    echo "### Value of PEER1_ORG${org}_CA is: ${!ROOTCERT}"
done
echo 
echo "###### Inside envVar.sh file"
echo "### Value of NAME_OF_ORD_ORG is: $NAME_OF_ORD_ORG"
echo "### Value of DOMAIN_OF_ORDERER_ORGANIZATION is: $DOMAIN_OF_ORDERER_ORGANIZATION"
echo "### Value of ORGANIZATION1_NAME is: $ORGANIZATION1_NAME"
echo "### Value of DOMAIN_OF_ORGANIZATION1 is: $DOMAIN_OF_ORGANIZATION1"
echo "### Value of ORGANIZATION2_NAME is: $ORGANIZATION2_NAME"
echo "### Value of DOMAIN_OF_ORGANIZATION2 is: $DOMAIN_OF_ORGANIZATION2"
echo "### Value of ORDERER_CA is: $ORDERER_CA"
#echo "### Value of PEER1_ORG1_CA is: $PEER1_ORG1_CA"
#echo "### Value of PEER1_ORG2_CA is: $PEER1_ORG2_CA"

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
    export CORE_PEER_LOCALMSPID="${NAME_OF_ORD_ORG}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer1.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/tlscacerts/tlsca.$DOMAIN_OF_ORDERER_ORGANIZATION-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/users/Admin.$DOMAIN_OF_ORDERER_ORGANIZATION/msp

    echo "#### Value of Orderer CORE_PEER_LOCALMSPID is $CORE_PEER_LOCALMSPID"
    echo "#### Value of Orderer CORE_PEER_TLS_ROOTCERT_FILE is $CORE_PEER_TLS_ROOTCERT_FILE"
    echo "#### Value of Orderer CORE_PEER_MSPCONFIGPATH is $CORE_PEER_MSPCONFIGPATH"
}

# Set environment variables for the peer org
setGlobals() {
  #local USING_ORG=""
    PEER=$1
    USING_ORG=$2

    echo 
    echo "Inside setGlobals and Value of PEER is $PEER"
    echo "Inside setGlobals and Value of USING_ORG is $USING_ORG"
    echo 
    echo "Using organization ${USING_ORG}"

    
    ORG_NAME="ORGANIZATION${USING_ORG}_NAME"
    ORG_DOMAIN="DOMAIN_OF_ORGANIZATION${USING_ORG}"
    ROOTCERT="PEER${PEER}_ORG${USING_ORG}_CA"
    export CORE_PEER_LOCALMSPID="${!ORG_NAME}MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/${!ORG_DOMAIN}/users/Admin.${!ORG_DOMAIN}/msp
    export CORE_PEER_TLS_ROOTCERT_FILE=${!ROOTCERT}
    echo
    echo "## CORE_PEER_LOCALMSPID is: $CORE_PEER_LOCALMSPID"
    echo "## CORE_PEER_MSPCONFIGPATH is: $CORE_PEER_MSPCONFIGPATH"
    echo "## CORE_PEER_TLS_ROOTCERT_FILE is: $CORE_PEER_TLS_ROOTCERT_FILE"
    echo

    if [ $DEV_MODE == "on" ]; then
        source ./scripts/createports.sh
        createPorts
        PORT="ORG${USING_ORG}_PEER${PEER}_LISTEN_PORT"
        echo "## Val of PORT is $PORT"
        PEER_LISTEN_PORT=${!PORT}
    else
        PEER_LISTEN_PORT=7051
    fi

    export CORE_PEER_ADDRESS=peer$PEER.${!ORG_DOMAIN}:$PEER_LISTEN_PORT        
    echo "## Value of CORE_PEER_ADDRESS is $CORE_PEER_ADDRESS"

    if [ "$VERBOSE" == "true" ]; then
        env | grep CORE
    fi
}

# joining channel with retry --> calling this in joinChannel() function in createChannel.sh
joinChannelRetry() {
	PEER=$1
	ORG=$2
  echo
  echo "Value of PEER is $PEER"
  echo "Value of ORG is $ORG"
  echo
	setGlobals $PEER $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block >&log.txt
		res=$?
		set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	echo
    ##
	ORG_DOMAIN="DOMAIN_OF_ORGANIZATION${ORG}"
	verifyResult $res "After $MAX_RETRY attempts, peer$PEER.${!ORG_DOMAIN} has failed to join channel '$CHANNEL_NAME' "
}

# parsePeerConnectionParameters $@
# Helper function that takes the parameters from a chaincode operation
# (e.g. invoke, query, instantiate) and checks for an even number of
# peers and associated org, then sets $PEER_CONN_PARMS and $PEERS
parsePeerConnectionParameters() {
    # 0 1 0 2   
    # $@ = stores all the arguments in a list of string
    # $* = stores all the arguments as a single string
    # $# = stores the number of arguments
    # check for uneven number of peer and org parameters
    echo "$#"
    if [ $(($# % 2)) -ne 0 ]; then
        exit 1
    fi

    PEER_CONN_PARMS=""
    PEERS=""
    while [ "$#" -gt 0 ]; do # 4 -->2 -->0
        setGlobals $1 $2
        ORG_DOMAIN="DOMAIN_OF_ORGANIZATION$2"
        PEER="peer$1.${!ORG_DOMAIN}"
        PEERS="$PEERS $PEER"
        PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
        # Always TLS enabled because of Raft
        TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER$1_ORG$2_CA")
        PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
        
        # shift by two to get the next pair of peer/org parameters. shift to left
        # if 1 2 3 then shift result in --> 2 3 _  
        shift
        shift
    done
    # remove leading space for output
    PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
    echo 
    echo "#### Inside parsePeerConnectionParams and value of PEERS is: $PEERS"
    echo "#### Inside parsePeerConnectionParams and value of PEER_CONN_PARMS is: $PEER_CONN_PARMS"
}

verifyResult() {
  if [ $1 -ne 1 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

changeOrg(){
    ORG=$1
    DOMAIN="DOMAIN_OF_ORGANIZATION${ORG}"
    ORG_DOMAIN=${!DOMAIN}
}