#!/bin/bash
# Taking Inputs from .env file
set -a
[ -f .env ] && . .env
set +a


function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`" # $1 for reading the first argument
}

#### ####
###   ###
#### #### 
if [ $DEV_MODE == "on" ]; then
    source ./scripts/createports.sh
    createPorts
    echo "#### Inside devmode and Value of PEER_LISTEN_PORT is: $PEER_LISTEN_PORT"
else
    PEER_LISTEN_PORT=7051 
fi

for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do

    ## Calling ccp-template create script
    ./scripts/create_ccpTemplate.sh

    ORG_DOMAIN="DOMAIN_OF_ORGANIZATION${ORG}"
    CAPORT="ORG${ORG}_PORT_NUMBER"
    ORG_NAME="ORGANIZATION${ORG}_NAME"
    ORG_SMALL_NAME="ORG${ORG}_NAME_SMALL"
    export ORG${ORG}_NAME_SMALL=`echo "${!ORG_NAME}" | tr '[:upper:]' '[:lower:]'`

    PEERPEM=./crypto-config/peerOrganizations/${!ORG_DOMAIN}/tlsca/tlsca.${!ORG_DOMAIN}-cert.pem
    CAPEM=./crypto-config/peerOrganizations/${!ORG_DOMAIN}/ca/ca.${!ORG_DOMAIN}-cert.pem

    ####
    echo "## value of ORG_SMALL_NAME is: ${!ORG_SMALL_NAME}"
    echo "### Org is: ${!ORG_DOMAIN}"
    echo "### CAPORT is: ${!CAPORT}"
    echo
    echo "## Value of PEERPEM is: $PEERPEM"
    echo "## Value of CAPEM is: $CAPEM"
    echo
    #### 

    #
    if [ $DEV_MODE == "on" ]; then
        for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
            PEER_LISTEN_PORT="ORG${ORG}_PEER${peer}_LISTEN_PORT"
            echo "### For Org$ORG and peer$peer, port is: ${!PEER_LISTEN_PORT}"
            sed -i -e "s/\${P${peer}PORT}/${!PEER_LISTEN_PORT}/" ./templates/ccp-template.json
            sed -i -e "s/\${P${peer}PORT}/${!PEER_LISTEN_PORT}/" ./templates/ccp-template.yaml
        done
    fi
    ##
    PP=$(one_line_pem $PEERPEM)
    CP=$(one_line_pem $CAPEM)
    echo
    echo "## PP is: $PP"
    echo
    echo "## CP is: $CP"
    echo
    sed -i -e "s/\${ORG_NAME}/${!ORG_NAME}/" \
        -i -e "s/\${ORG_DOMAIN}/${!ORG_DOMAIN}/" \
        -i -e "s/\${CAPORT}/${!CAPORT}/" \
        -i -e "s#\${PEERPEM}#$PP#" \
        -i -e "s#\${CAPEM}#$CP#" ./templates/ccp-template.json
    
    sed -i -e "s/\${ORG_NAME}/${!ORG_NAME}/" \
        -i -e "s/\${ORG_DOMAIN}/${!ORG_DOMAIN}/" \
        -i -e "s/\${CAPORT}/${!CAPORT}/" \
        -i -e "s#\${PEERPEM}#$PP#" \
        -i -e "s#\${CAPEM}#$CP#" ./templates/ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'

    mv  ./templates/ccp-template.json ./crypto-config/peerOrganizations/${!ORG_DOMAIN}/connection-${!ORG_SMALL_NAME}.json
    mv  ./templates/ccp-template.yaml ./crypto-config/peerOrganizations/${!ORG_DOMAIN}/connection-${!ORG_SMALL_NAME}.yaml
    #echo "$(json_ccp ${!ORG_NAME} ${!ORG_DOMAIN} $P0PORT $P1PORT ${!CAPORT} $PEERPEM $CAPEM)" > ./crypto-config/peerOrganizations/${!ORG_DOMAIN}/connection-${!ORG_SMALL_NAME}.json
    #echo "$(yaml_ccp ${!ORG_NAME} ${!ORG_DOMAIN} $P0PORT $P1PORT ${!CAPORT} $PEERPEM $CAPEM)" > ./crypto-config/peerOrganizations/${!ORG_DOMAIN}/connection-${!ORG_SMALL_NAME}.yaml
done

