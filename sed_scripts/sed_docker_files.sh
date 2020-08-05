#set -ev
#!/bin/bash

# Taking Inputs from .env file
set -a
[ -f .env ] && . .env
set +a

#cat .env
pwd

#export ORGANIZATION_NAME_LOWERCASE=`echo "$ORGANIZATION1_NAME" | tr '[:upper:]' '[:lower:]'`

echo "##################################################################################"
echo "################### Creating Orderer and Peer docker files #######################"
echo "##################################################################################"

function createOrdererComposeFile() {
    echo "### Number of orderer nodes: $NUMBER_OF_ORDERER_NODES"
    # editing orderer files.
    # $(seq 1 "$@") ---> from 1 to Number_passed_when_calling_function (kind of range loop)
    for NUMBER in $(seq 1 "$NUMBER_OF_ORDERER_NODES"); do
        if [ $DEV_MODE = on ]; then
            echo "Inside dev mode"
            ORDERER_LISTEN_PORT="ORDERER${NUMBER}_LISTEN_PORT"
            ORDERER_OPERATION_PORT="ORDERER${NUMBER}_OPERATION_PORT"
            ORDERER_LISTEN_PORT=${!ORDERER_LISTEN_PORT}
            ORDERER_OPERATION_PORT=${!ORDERER_OPERATION_PORT}           
        else
            echo "Inside else"
            ORDERER_LISTEN_PORT=7050
            ORDERER_OPERATION_PORT=4443
        fi
        sed -e 's/orderer_organization_name/'$NAME_OF_ORD_ORG'/g' \
            -e 's/orderer_organization_domain/'$DOMAIN_OF_ORDERER_ORGANIZATION'/g' \
            -e 's/number/'$NUMBER'/g' \
            -e 's/orderer_listen_port/'$ORDERER_LISTEN_PORT'/g' \
            -e 's/orderer_operation_port/'$ORDERER_OPERATION_PORT'/g' templates/docker-compose-orderer_temp.yaml > ./docker/docker-compose-orderer$NUMBER.yaml
    done        
}

function createPeerComposeFile() {
    
    for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
        echo 
        echo "## Looping for Org$ORG"
        echo     
        ORG_NAME="ORGANIZATION${ORG}_NAME"
        ORG_DOMAIN="DOMAIN_OF_ORGANIZATION${ORG}"
        GOSSIP_BOOTSTRAP=""
        echo "## Value of ORG_NAME is ${!ORG_NAME}"
        echo "## Value of ORG_DOMAIN is ${!ORG_DOMAIN}"
        # Converting it into lowercase
        ORG_NAME_LOWERCASE=`echo "${!ORG_NAME}" | tr '[:upper:]' '[:lower:]'`
        echo "## Value of ORG_NAME_LOWERCASE is $ORG_NAME_LOWERCASE"
        
        for PEER in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
            echo 
            echo "## Looping for PEER$PEER"
            echo "##  Value of ORG_NAME is: $ORG_NAME_LOWERCASE"
            echo 
            if [ $DEV_MODE == "on" ]; then
                PEER_LISTEN_PORT="ORG${ORG}_PEER${PEER}_LISTEN_PORT"
                PEER_CC_LISTEN_PORT="ORG${ORG}_PEER${PEER}_CC_LISTEN_PORT"
                PEER_OPERATION_PORT="ORG${ORG}_PEER${PEER}_OPERATION_PORT"
                COUCHDB_PORT="ORG${ORG}_PEER${PEER}_COUCHDB_PORT"

                PEER_LISTEN_PORT=${!PEER_LISTEN_PORT}
                PEER_CC_LISTEN_PORT=${!PEER_CC_LISTEN_PORT}
                PEER_OPERATION_PORT=${!PEER_OPERATION_PORT}
                COUCHDB_PORT=${!COUCHDB_PORT}
                echo
                echo "## Value of PEER_LISTEN_PORT is: $PEER_LISTEN_PORT"
                echo "## Value of PEER_CC_LISTEN_PORT is: $PEER_CC_LISTEN_PORT"
                echo "## Value of PEER_OPERATION_PORT is: $PEER_OPERATION_PORT"
                echo "## Value of COUCHDB_PORT is: $COUCHDB_PORT"
                echo
            else 
                PEER_LISTEN_PORT=7051
                PEER_CC_LISTEN_PORT=7052
                PEER_OPERATION_PORT=7443
                COUCHDB_PORT=5984
            fi    
            GOSSIP_BOOTSTRAP=""
            if [ $NUMBER_OF_PEER_NODES_PER_ORG -eq 1 ]; then
                GOSSIP_BOOTSTRAP="peer$PEER.${!ORG_DOMAIN}:${PEER_LISTEN_PORT}"
            elif [ $NUMBER_OF_PEER_NODES_PER_ORG -eq 2 ]; then
                if [ $DEV_MODE == "on" ]; then
                    
                    if [ $PEER -eq 1 ]; then
                        PORT="ORG${ORG}_PEER2_LISTEN_PORT"
                        GOSSIP_BOOTSTRAP="peer2.${!ORG_DOMAIN}:${!PORT}"
                    else
                        PORT="ORG${ORG}_PEER1_LISTEN_PORT"
                        GOSSIP_BOOTSTRAP="peer1.${!ORG_DOMAIN}:${!PORT}" 
                    fi
                else
                    if [ $PEER -eq 1 ]; then    
                        GOSSIP_BOOTSTRAP="peer2.${!ORG_DOMAIN}:${PEER_LISTEN_PORT}"
                    else
                        GOSSIP_BOOTSTRAP="peer1.${!ORG_DOMAIN}:${PEER_LISTEN_PORT}" 
                    fi
                fi    
            else
                for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
                    if [ $DEV_MODE == "on" ]; then
                        PORT="ORG${ORG}_PEER${peer}_LISTEN_PORT"
                        PORT=${!PORT}
                    else
                        PORT=$PEER_LISTEN_PORT
                    fi        
                    if [ $peer -ne $PEER ]; then
                        if [ $peer -eq $NUMBER_OF_PEER_NODES_PER_ORG ]; then
                            GOSSIP_BOOTSTRAP+="peer$peer.${!ORG_DOMAIN}:$PORT"  
                        else
                            GOSSIP_BOOTSTRAP+="peer$peer.${!ORG_DOMAIN}:$PORT,"  
                        fi
                    fi    
                done
                if [ $PEER -eq $NUMBER_OF_PEER_NODES_PER_ORG ]; then
                    #echo "Inside if"
                    GOSSIP_BOOTSTRAP=`echo "$GOSSIP_BOOTSTRAP" | sed 's/,[[:blank:]]*$//g'` 
                    #echo "### Value of GOSSIP_BOOTSTRAP for peer$PEER is: $GOSSIP_BOOTSTRAP"   
                fi    
            fi

            echo "## Final Value of GOSSIP_BOOTSTRAP is: $GOSSIP_BOOTSTRAP"           
            echo "## PEER_LISTEN_PORT is $PEER_LISTEN_PORT"
            echo "## PEER_CC_LISTEN_PORT is $PEER_CC_LISTEN_PORT"
            echo "## PEER_OPERATION_PORT is $PEER_OPERATION_PORT"
            #core_peer_gossip_bootstrap
            if [[ $PEER -eq 1 && $NUMBER_OF_PEER_NODES_PER_ORG -lt 2 ]]; then 
                echo " Line 133 and Inside If condition"  
                sed -e 's/organization_name/'${!ORG_NAME}'/g' \
                    -e 's/organization_small_name/'$ORG_NAME_LOWERCASE'/g' \
                    -e 's/organization_domain/'${!ORG_DOMAIN}'/g' \
                    -e 's/number/'$PEER'/g' \
                    -e 's/peer_listen_port/'$PEER_LISTEN_PORT'/g' \
                    -e 's/couch_db_port/'$COUCHDB_PORT'/g' \
                    -e 's/core_peer_gossip_bootstrap/'$GOSSIP_BOOTSTRAP'/g' \
                    -e 's/peer_cc_listen_port/'$PEER_CC_LISTEN_PORT'/g' \
                    -e 's/peer_operation_port/'$PEER_OPERATION_PORT'/g' templates/docker-compose-peer-org_template.yaml > ./docker/docker-compose-peer$PEER-$ORG_NAME_LOWERCASE.yaml

            else 
                echo " Line 145 and Inside else condition"            
                sed -e 's/organization_name/'${!ORG_NAME}'/g' \
                    -e 's/organization_small_name/'$ORG_NAME_LOWERCASE'/g' \
                    -e 's/organization_domain/'${!ORG_DOMAIN}'/g' \
                    -e 's/number/'$PEER'/g' \
                    -e 's/peer_listen_port/'$PEER_LISTEN_PORT'/g' \
                    -e 's/couch_db_port/'$COUCHDB_PORT'/g' \
                    -e 's/core_peer_gossip_bootstrap/'$GOSSIP_BOOTSTRAP'/g' \
                    -e 's/peer_cc_listen_port/'$PEER_CC_LISTEN_PORT'/g' \
                    -e 's/peer_operation_port/'$PEER_OPERATION_PORT'/g' templates/docker-compose-peer-org_template.yaml > ./docker/docker-compose-peer$PEER-$ORG_NAME_LOWERCASE.yaml
            fi
            # cli files 
            sed -e 's/organization_name/'${!ORG_NAME}'/g' \
                -e 's/organization_small_name/'$ORG_NAME_LOWERCASE'/g' \
                -e 's/number/'$PEER'/g' \
                -e 's/peer_listen_port/'$PEER_LISTEN_PORT'/g' \
                -e 's/organization_domain/'${!ORG_DOMAIN}'/g' templates/docker-compose-cli-peer-org_temp.yaml > ./docker/docker-compose-cli-peer$PEER-$ORG_NAME_LOWERCASE.yaml
        done
    done    
       
}

# Calling above functions
if [ $ORDERER_FLAG == "true" ];then
    createOrdererComposeFile
fi

if [ $DEV_MODE == "on" ]; then
    source ./scripts/createports.sh
    createPorts
    echo "#### Inside sed_docker file devmode and Value of PEER_LISTEN_PORT is: $PEER_LISTEN_PORT"
fi
# calling peer compose file
createPeerComposeFile
echo "###################################################################################"
echo "################### Completed Orderer and Peer docker files #######################"
echo "###################################################################################"
