#!/bin/bash

# Hello World Program in Bash Shell
set -a
[ -f .env ] && . .env
set +a

echo "Hello World!"

# import utils
. scripts/envVar.sh

# parsePeerConnectionParameters() {
#   # check for uneven number of peer and org parameters

#   PEER_CONN_PARMS=""
#   PEERS=""
#   while [ "$#" -gt 0 ]; do
#     #setGlobals $1
#     PEER="peer0.org$1" # peer0.org1
#     PEERS="$PEERS $PEER" # "peer0.org1"
#     echo
#     echo "Value of PEER is: $PEER"
#     echo "Value of PEERS is: $PEERs"
#     echo
#     # " --peerAddresses "
#     PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
#     echo 
#     echo "Value of PEER_CONN_PARAMS is: $PEER_CONN_PARMS"
#     echo
#     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "true" ]; then
#       TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG${1}_CA")
#       PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
#       echo 
#       echo "Value of PEER_CONN_PARAMS is: $PEER_CONN_PARMS"
#       echo
#     fi
#     # shift by two to get the next pair of peer/org parameters
#     shift
#   done
#   # remove leading space for output
#   PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
#   echo 
#   echo "Value of PEERS is: $PEERS"
#   echo
# }

# for a in 1 2; do
#     for b in 0 1; do
#         parsePeerConnectionParameters a
#     done
# done       


# # TEST 2
# echo 
# echo "##### TEST 2"
# echo 

# checkCommitReadiness() {
#   VERSION=$1
#   PEER=$2
#   ORG=$3
#   CHANNEL_NAME="mychannel"
#   DELAY=2
#   TIMEOUT=10
#   shift 3
#   setGlobals $PEER $ORG
#   echo "===================== Checking the commit readiness of the chaincode definition on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
#   local rc=1
#   local starttime=$(date +%s)

#   # continue to poll
#   # we either get a successful response, or reach TIMEOUT
#   while
#     x=$(date +%s)
#     y=$x-$starttime
#     echo "value of xy is $y"
#     test "$(($(date +%s) - starttime))" -lt "$TIMEOUT" -a $rc -ne 0
#     echo "value of test is $test"
#   do
#     sleep $DELAY
#     set -x
#     echo "Attempting to check the commit readiness of the chaincode definition on peer${PEER}.org${ORG} ...$(($(date +%s) - starttime)) secs"
#     #peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name mycc $PEER_CONN_PARMS --version ${VERSION} --sequence ${VERSION} --output json --init-required >&log.txt
#     res=$?
#     set +x
#     test $res -eq 0 || continue
#     let rc=0
#     for var in "$@"
#     do
#         grep "$var" log.txt &>/dev/null || let rc=1
#     done
#   done
#   echo
#   cat log.txt
#   if test $rc -eq 0; then
#     echo "===================== Checking the commit readiness of the chaincode definition successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
#   else
#     echo "!!!!!!!!!!!!!!! Check commit readiness result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
#     echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
#     echo
#     exit 1
#   fi
# }

#checkCommitReadiness 1 0 1 "\"${ORGANIZATION1_NAME}MSP\": true" "\"${ORGANIZATION1_NAME2}MSP\": false"

################
# TEST 3
################
# echo
# echo "##### TEST 3"
# echo 

# function checkif() {
#   DEV_MODE="on"
#   PEER=1
#   for org in $(seq 1 "$NUMBER_OF_PEER_ORGS");do
#     echo "Looping for Org: $org"
#     for var in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
#       echo "## Looping for Peer: $var"
#       if [ $DEV_MODE == on ]; then
#         echo "Inside dev mode"
#         PEER=$((PEER+1000))
#         if [ $var -eq 1 ]; then
#           A="testing1"
#           echo "Value of peer is: $PEER"
#         elif [ $var -eq 2 ]; then
#           A="testing2"
#           echo "Value of peer2 is: $PEER"
#         elif [ $var -eq 3 ]; then 
#           A="testing3"
#           echo "Value of peer3is: $PEER" 
#         fi  
#       else 
#         A="OK"
#         echo "Value of peer3is: $PEER" 
#       fi
#       echo
#       echo "#### value of A is: $A"
      
#     done    
#   done
# }

# checkif 2

# for org in $(seq 1 "$NUMBER_OF_PEER_ORGS");do
#   echo "Looping for Org: $org"
  
#   # 1 2
#   # 1 2 
#   # 1 != 1 --> notappend, 2 != 1 --> append
#   # 1 != 2 --> append, 2 != 2 --> notappend
#   # peer2, peer1 
#   for var in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do  # 1 2
#     alpha=""
#     for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do # 1 2
#       if [ $peer -ne $var ]; then
#         if [ $peer -eq $NUMBER_OF_PEER_NODES_PER_ORG ]; then
#           alpha+="peer$peer.org$org:port"  
#         else
#           alpha+="peer$peer.org$org:port, "  
#         fi
#       fi
#     done
#     if [ $var -eq $NUMBER_OF_PEER_NODES_PER_ORG ]; then
#       echo "Inside if"
#       alpha=`echo "$alpha" | sed 's/,[[:blank:]]*$//g'` 
#       echo "### Value of alpha for peer$var is: $alpha"
#     else
#       echo "### Value of alpha for peer$var is: $alpha"
#     fi  
#   done
#   echo "## value of alpha is: $alpha"
# done

# echo 
# echo 
# echo "########################## TEST 4 ############################"

# function createPorts(){
#     PEER_LISTEN_PORT=6051
#     PEER_CC_LISTEN_PORT=6052
#     PEER_OPERATION_PORT=6443
#     COUCHDB_PORT=4984
#     for org in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do 
#         echo "Looping for org$org"
#         for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
#           echo "Looping for peer$peer"
#           PLP=`expr $peer \* 1000` # 2*1000
#           echo $PLP
#           export ORG${org}_PEER${peer}_LISTEN_PORT=`expr $PEER_LISTEN_PORT + $PLP`
#           export ORG${org}_PEER${peer}_CC_LISTEN_PORT=`expr $PEER_CC_LISTEN_PORT + $PLP`
#           export ORG${org}_PEER${peer}_OPERATION_PORT=`expr $PEER_OPERATION_PORT + $PLP`
#           export ORG${org}_PEER${peer}_COUCHDB_PORT=`expr $COUCHDB_PORT + $PLP`

#           p1="ORG${org}_PEER${peer}_LISTEN_PORT"
#           p2="ORG${org}_PEER${peer}_CC_LISTEN_PORT"
#           p3="ORG${org}_PEER${peer}_OPERATION_PORT"
#           p4="ORG${org}_PEER${peer}_COUCHDB_PORT"
          
#           echo "value of p1 is ${!p1}"
#           echo "value of p2 is ${!p2}"
#           echo "value of p3 is ${!p3}"
#           echo "value of p4 is ${!p4}"    
#         done
#         PEER_LISTEN_PORT=${!p1}
#         PEER_CC_LISTEN_PORT=${!p2}
#         PEER_OPERATION_PORT=${!p3}
#         COUCHDB_PORT=${!p4}
        
#     done    
#     #printenv
# }

# createPorts
# conditions
# if number of peers per org ==1 then
#CORE_GOSSIP = peer1.beta.com:7051
# If number of peers per org == 2 then 
 #CORE_GOSSIP =peer2.beta.com:8051  <-- peer1
 #CORE_GOSSIP =peer1.beta.com:7051  <-- peer2
# if number of peers > 2 then
## if peer 1
    #CORE_GOSSIP = peer2.beta.com:8051, peer3.beta.com:9051, peer4.beta.com:10051 .... up to number of peers expect the current peer number 
 #else

# if [ $PEER -eq 1 ]; then
#                     PEER_LISTEN_PORT=$PEER1_LISTEN_PORT
#                     PEER_OU_LISTEN_PORT=$PEER2_LISTEN_PORT
#                     PEER_CC_LISTEN_PORT=$PEER1_CC_LISTEN_PORT
#                     PEER_OPERATION_PORT=$PEER1_OPERATION_PORT
#                     PEER_CROSS=peer2
#                 elif [ $PEER -eq 2 ]; then
#                     PEER_LISTEN_PORT=$PEER2_LISTEN_PORT
#                     PEER_OU_LISTEN_PORT=$PEER1_LISTEN_PORT
#                     PEER_CC_LISTEN_PORT=$PEER2_CC_LISTEN_PORT
#                     PEER_OPERATION_PORT=$PEER2_OPERATION_PORT
#                     PEER_CROSS=peer1
#                 elif [ $PEER -eq 3 ]; then
#                     PEER_LISTEN_PORT=$PEER3_LISTEN_PORT
#                     PEER_OU_LISTEN_PORT=$PEER2_LISTEN_PORT
#                     PEER_CC_LISTEN_PORT=$PEER3_CC_LISTEN_PORT
#                     PEER_OPERATION_PORT=$PEER3_OPERATION_PORT        
#                     PEER_CROSS=peer2
#                 elif [ $PEER -eq 4 ]; then
#                     PEER_LISTEN_PORT=$PEER4_LISTEN_PORT
#                     PEER_OU_LISTEN_PORT=$PEER2_LISTEN_PORT
#                     PEER_CC_LISTEN_PORT=$PEER4_CC_LISTEN_PORT
#                     PEER_OPERATION_PORT=$PEER4_OPERATION_PORT    
#                     PEER_CROSS=peer2
#                 elif [ $PEER -eq 5 ]; then
#                     PEER_LISTEN_PORT=$PEER5_LISTEN_PORT
#                     PEER_OU_LISTEN_PORT=$PEER2_LISTEN_PORT
#                     PEER_CC_LISTEN_PORT=$PEER5_CC_LISTEN_PORT
#                     PEER_OPERATION_PORT=$PEER5_OPERATION_PORT
#                     PEER_CROSS=peer2
#                 fi


# for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
#     if [ $ORG -eq 1 ]; then
#         ORG_NAME=$ORGANIZATION1_NAME
#         ORG_LOWERCASE=`echo "$ORG_NAME" | tr '[:upper:]' '[:lower:]'`
#     elif [ $ORG -eq 2 ]; then
#         ORG_NAME=$ORGANIZATION2_NAME
#         ORG_LOWERCASE=`echo "$ORG_NAME" | tr '[:upper:]' '[:lower:]'`
#     elif [ $ORG -eq 3 ]; then
#         ORG_NAME=$ORGANIZATION3_NAME
#         ORG_LOWERCASE=`echo "$ORG_NAME" | tr '[:upper:]' '[:lower:]'`        
#     elif [ $ORG -eq 4 ]; then
#         ORG_NAME=$ORGANIZATION4_NAME
#         ORG_LOWERCASE=`echo "$ORG_NAME" | tr '[:upper:]' '[:lower:]'`
#     elif [ $ORG -eq 5 ]; then
#         ORG_NAME=$ORGANIZATION5_NAME
#         ORG_LOWERCASE=`echo "$ORG_NAME" | tr '[:upper:]' '[:lower:]'`    
#     fi   

################################
##### TEST 5
################################

# echo -n "Organizations:" > a.yaml

# echo -n "
#     - &orderer_organization_name
#         Name: orderer_organization_name
#         ID: orderer_organization_nameMSP
#         MSPDir: crypto-config/ordererOrganizations/orderer_organization_domain/msp
#         Policies:
#             Readers:
#                 Type: Signature
#                 Rule: \"OR('orderer_organization_nameMSP.member')\"
#             Writers:
#                 Type: Signature
#                 Rule: \"OR('orderer_organization_nameMSP.member')\"
#             Admins:
#                 Type: Signature
#                 Rule: \"OR('orderer_organization_nameMSP.admin')\"

#         OrdererEndpoints:
#             - orderer1_address:7050
#             - orderer2_address:8050
#             - orderer3_address:9050
# " >> a.yaml

# for org in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
# echo -n "   
#     - &organization${org}_name
#         # DefaultOrg defines the organization which is used in the sampleconfig
#         # of the fabric.git development environment
#         Name: organization${org}_name

#         # ID to load the MSP definition as
#         ID: organization${org}_nameMSP

#         MSPDir: crypto-config/peerOrganizations/organization${org}_domain/msp

#         # Policies defines the set of policies at this level of the config tree
#         # For organization policies, their canonical path is usually
#         #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
#         Policies:
#             Readers:
#                 Type: Signature
#                 Rule: \"OR('organization${org}_nameMSP.admin', 'organization${org}_nameMSP.peer', 'organization${org}_nameMSP.client')\"
#             Writers:
#                 Type: Signature
#                 Rule: \"OR('organization${org}_nameMSP.admin', 'organization${org}_nameMSP.client')\"
#             Admins:
#                 Type: Signature
#                 Rule: \"OR('organization${org}_nameMSP.admin')\"
#             Endorsement:    
#                 Type: Signature
#                 Rule: \"OR('organization${org}_nameMSP.peer')\"

#         # leave this flag set to true.
#         AnchorPeers:
#             # AnchorPeers defines the location of peers which can be used
#             # for cross org gossip communication.  Note, this value is only
#             # encoded in the genesis block in the Application section context
#             - Host: org${org}_anchorpeer_address
#               Port: org${org}_anchor_peer_port
# " >> a.yaml

# done

# echo -n "
# Capabilities:
#     # Channel capabilities apply to both the orderers and the peers and must be
#     # supported by both.
#     # Set the value of the capability to true to require it.
#     Channel: &ChannelCapabilities
#         V2_0: true

#     # Orderer capabilities apply only to the orderers, and may be safely
#     # used with prior release peers.
#     # Set the value of the capability to true to require it.
#     Orderer: &OrdererCapabilities
#         V2_0: true

#     # Application capabilities apply only to the peer network, and may be safely
#     # used with prior release orderers.
#     # Set the value of the capability to true to require it.
#     Application: &ApplicationCapabilities
#         V2_0: true

# Application: &ApplicationDefaults

#     # Organizations is the list of orgs which are defined as participants on
#     # the application side of the network
#     Organizations:

#     # Policies defines the set of policies at this level of the config tree
#     # For Application policies, their canonical path is
#     #   /Channel/Application/<PolicyName>
#     Policies:
#         Readers:
#             Type: ImplicitMeta
#             Rule: \"ANY Readers\"
#         Writers:
#             Type: ImplicitMeta
#             Rule: \"ANY Writers\"
#         Admins:
#             Type: ImplicitMeta
#             Rule: \"ANY Admins\"
#         LifecycleEndorsement:
#             Type: ImplicitMeta
#             Rule: \"MAJORITY Endorsement\"
#         Endorsement:
#             Type: ImplicitMeta
#             Rule: \"MAJORITY Endorsement\"

#     Capabilities:
#         <<: *ApplicationCapabilities        
# " >> a.yaml

# echo -n '
# Orderer: &OrdererDefaults
#     Addresses:
#         - orderer1_address:7050
#         - orderer2_address:8050
#         - orderer3_address:9050 
        
#     OrdererType: etcdraft
#     EtcdRaft:
#         Consenters:
#         - Host: orderer1_address
#           Port: 7050
#           ClientTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer1.orderer_organization_domain/tls/server.crt
#           ServerTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer1.orderer_organization_domain/tls/server.crt
#         - Host: orderer2_address
#           Port: 8050
#           ClientTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer2.orderer_organization_domain/tls/server.crt
#           ServerTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer2.orderer_organization_domain/tls/server.crt
#         - Host: orderer3_address
#           Port: 9050
#           ClientTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer3.orderer_organization_domain/tls/server.crt
#           ServerTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer3.orderer_organization_domain/tls/server.crt      
    
#         # Options to be specified for all the etcd/raft nodes. The values here
#         # are the defaults for all new channels and can be modified on a
#         # per-channel basis via configuration updates.
#         Options:
#             # TickInterval is the time interval between two Node.Tick invocations.
#             TickInterval: 500ms

#             # ElectionTick is the number of Node.Tick invocations that must pass
#             # between elections. That is, if a follower does not receive any
#             # message from the leader of current term before ElectionTick has
#             # elapsed, it will become candidate and start an election.
#             # ElectionTick must be greater than HeartbeatTick.
#             ElectionTick: 10

#             # HeartbeatTick is the number of Node.Tick invocations that must
#             # pass between heartbeats. That is, a leader sends heartbeat
#             # messages to maintain its leadership every HeartbeatTick ticks.
#             HeartbeatTick: 1

#             # MaxInflightBlocks limits the max number of in-flight append messages
#             # during optimistic replication phase.
#             MaxInflightBlocks: 5

#             # SnapshotIntervalSize defines number of bytes per which a snapshot is taken
#             SnapshotIntervalSize: 20 MB 
#     # Batch Timeout: The amount of time to wait before creating a batch/block
#     BatchTimeout: 2s
#     # Batch Size: Controls the number of messages batched into a block
#     BatchSize:
#         # Max Message Count: The maximum number of messages to permit in a batch
#         MaxMessageCount: 10
#         # Absolute Max Bytes: The absolute maximum number of bytes allowed for
#         # the serialized messages in a batch.
#         AbsoluteMaxBytes: 99 MB
#         # Preferred Max Bytes: The preferred maximum number of bytes allowed for
#         # the serialized messages in a batch. A message larger than the preferred
#         # max bytes will result in a batch larger than preferred max bytes.
#         PreferredMaxBytes: 512 KB
    
#     # Organizations is the list of orgs which are defined as participants on
#     # the orderer side of the network
#     Organizations:

#     # Policies defines the set of policies at this level of the config tree
#     # For Orderer policies, their canonical path is
#     #   /Channel/Orderer/<PolicyName>
#     Policies:
#         Readers:
#             Type: ImplicitMeta
#             Rule: "ANY Readers"
#         Writers:
#             Type: ImplicitMeta
#             Rule: "ANY Writers"
#         Admins:
#             Type: ImplicitMeta
#             Rule: "ANY Admins"
#         BlockValidation:
#             Type: ImplicitMeta
#             Rule: "ANY Writers"

# ' >> a.yaml

# echo -n '
# Channel: &ChannelDefaults
#     # Policies defines the set of policies at this level of the config tree
#     # For Channel policies, their canonical path is
#     #   /Channel/<PolicyName>
#     Policies:
#         # Who may invoke the "Deliver" API
#         Readers:
#             Type: ImplicitMeta
#             Rule: "ANY Readers"
#         # Who may invoke the "Broadcast" API
#         Writers:
#             Type: ImplicitMeta
#             Rule: "ANY Writers"
#         # By default, who may modify elements at this config level
#         Admins:
#             Type: ImplicitMeta
#             Rule: "ANY Admins"

#     Capabilities:
#         <<: *ChannelCapabilities

# ' >> a.yaml
# echo -n '
# Profiles:
#     TwoOrgsOrdererGenesis:
#         <<: *ChannelDefaults
#         Orderer:
#             <<: *OrdererDefaults
#             Organizations:
#                 - *orderer_organization_name
#             Capabilities:
#                 <<: *OrdererCapabilities    
#         Consortiums:
#             SampleConsortium:
#                 Organizations:
# ' >> a.yaml
# for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
# echo -n "
#                   - *organization${ORG}_name
# "  | sed '/^[[:space:]]*$/d' >> a.yaml
# done

# echo -n '
#     TwoOrgsChannel:
#         Consortium: SampleConsortium
#         <<: *ChannelDefaults
#         Application:
#             <<: *ApplicationDefaults
#             Organizations:
# ' >> a.yaml

# for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
# echo -n "
#               - *organization${ORG}_name
# " | sed '/^[[:space:]]*$/d' >> a.yaml
# done

# echo -n "
#         Capabilities:
#             <<: *ApplicationCapabilities
# " >> a.yaml


#awk 'NF' a.yaml > b.yaml # remove all the row spaces
#awk '{ /^\s*$/?b++:b=0; if (b<=1) print }' a.yaml > b.yaml  # remove multiple empty lines to 1 line 
#awk '!NF {if (++n <= 2) print; next}; {n=0;print}'


####################################
### TEST 5
####################################
# for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
#     ORG_NAME="ORGANIZATION${ORG}_NAME"    
#     # Converting it into lowercase
#     ORG_NAME_LOWERCASE=`echo "${!ORG_NAME}" | tr '[:upper:]' '[:lower:]'`
#     echo "## Value of ORG_NAME_LOWERCASE is $ORG_NAME_LOWERCASE"

#     cmd="IMAGE_TAG=\${IMAGETAG} docker-compose"
#     for PEER in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
#         cmd+=" -f ./docker/docker-compose-peer${PEER}-${ORG_NAME_LOWERCASE}.yaml"
#     done
#     cmd+=" up -d 2>&1"
#     echo
#     echo "## Value of cmd is: $cmd"
#     eval "$cmd"
# done

# echo "# Final Value of cmd is: $cmd"
# $@ = stores all the arguments in a list of string
# $* = stores all the arguments as a single string
# $# = stores the number of arguments
# echo "$@" 
# echo "$*"
# echo "$#"
# if [ $(($# % 2)) -ne 0 ]; then
#     echo "its happening"    
# else 
#     echo "shit"
# fi

# while [ "$#" -gt 0 ]; do
#     echo "$#"
#     shift
#     shift
# done
function approveForMyOrg(){
    echo "testing $1 $2"
}

function checkCommitReadiness(){
    echo "testtwo $1 $2"
    echo 
    shift 2
    echo " string is:"
    echo $1
}
for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
    #echo "## Loop for $ORG"
    approveForMyOrg 1 $ORG
    ## check whether the chaincode definition is ready to be committed
    ## expect org1 to have approved and org2 not to
    STR=""
    for org in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
        #echo "## Inner Loop for $org"
        ORG_NAME="ORGANIZATION${org}_NAME"
        if [ $org -eq $ORG ]; then
            FLAG=true
        elif [ $org -lt $ORG ]; then
            FLAG=true
        else
            FLAG=false
        fi
        STR+='"\"'${!ORG_NAME}'MSP\": '$FLAG'" '
        #echo 
        #echo "Value of flag is: $FLAG"
        #echo "Value of STR is: $STR"
        
    done
    
    echo "## Final value of STR is: $STR"
    for o in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
        echo checkCommitReadiness 1 $o $STR
    done
done    

#############################
function pnt(){
 echo "$@"
}

echo 
echo 
echo " ############################################################"
echo 
echo " Other test"
for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
    str+="1 $ORG "
done
$( eval echo pnt $str)

id=$(eval id -u)
echo 
echo "aa"
echo $id
