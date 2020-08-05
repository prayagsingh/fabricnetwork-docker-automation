#set -ev
#!/bin/bash

# Reagin env variables
set -a
[ -f .env ] && . .env
set +a

echo ""
echo " #####################################################"
echo " ########### Creating configtx.yaml file #############"
echo " #####################################################"
echo ""

# Substitutes organizations information in the configtx template to match organizations name, domain and ip address
function sedOrderer() {
     
    sed -i -e 's/orderer_organization_name/'$NAME_OF_ORD_ORG'/g' \
        -i -e 's/orderer_organization_domain/'$DOMAIN_OF_ORDERER_ORGANIZATION'/g' templates/configtx_template.yaml
       
    for ORD in $(seq 1 "$NUMBER_OF_ORDERER_NODES"); do
        echo "## Looping for Orderer: $ORD"
        ADDR="orderer${ORD}.${DOMAIN_OF_ORDERER_ORGANIZATION}"
        echo ${ADDR}
        sed -i -e "s/orderer${ORD}_address/"${ADDR}"/g" templates/configtx_template.yaml #configtx_tmp`expr $ORD + 1`.yaml
    done
    #exit 1
}

function sedOrgs() {    
    for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do       
        ORG_NAME="ORGANIZATION${ORG}_NAME"
        ORG_DOMAIN="DOMAIN_OF_ORGANIZATION${ORG}"
        ORG_ANCHOR_PEER="ORG${ORG}_ANCHOR_PEER"
        if [ $DEV_MODE == "on" ]; then
            ORG_ANCHOR_PEER_PORT="ORG${ORG}_PEER1_LISTEN_PORT"
        else
            ORG_ANCHOR_PEER_PORT=7051
        fi    
        #ORG_LOWERCASE=`echo "${!ORG_NAME}" | tr '[:upper:]' '[:lower:]'` 

        echo 
        echo "### ${!ORG_NAME}"
        echo "### ${!ORG_DOMAIN}"
        echo "### ${!ORG_ANCHOR_PEER}"
        if [ $DEV_MODE == "on" ]; then
            echo "### ${!ORG_ANCHOR_PEER_PORT}"
        else
            echo "### ${ORG_ANCHOR_PEER_PORT}"    
        fi
        
        if [ $ORDERER_FLAG == "true" ];then
            sed -i -e "s/organization${ORG}_name/"${!ORG_NAME}"/g" \
                -i -e "s/organization${ORG}_domain/"${!ORG_DOMAIN}"/g" \
                -i -e "s/org${ORG}_anchorpeer_address/"${!ORG_ANCHOR_PEER}"/g" \
                -i -e "s/org${ORG}_anchor_peer_port/"${!ORG_ANCHOR_PEER_PORT}"/g" templates/configtx_template.yaml
        else
            sed -i -e "s/organization${ORG}_name/"${!ORG_NAME}"/g" \
                -i -e "s/organization${ORG}_domain/"${!ORG_DOMAIN}"/g" \
                -i -e "s/org${ORG}_anchorpeer_address/"${!ORG_ANCHOR_PEER}"/g" \
                -i -e "s/org${ORG}_anchor_peer_port/"${!ORG_ANCHOR_PEER_PORT}"/g" templates/configtx_template.yaml 
        fi        
    done     
}

# removing previous files
for ORD in $(seq 1 "$NUMBER_OF_ORDERER_NODES"); do 
 rm -f configtx_tmp${ORD}.yaml
done

pwd
if [ $DEV_MODE == "on" ]; then
    source ./scripts/createports.sh
    createPorts
    echo "#### Inside devmode and Value of PEER_LISTEN_PORT is: $PEER_LISTEN_PORT"
else
    PEER_LISTEN_PORT=7051 
fi

# creating configtx.yaml template 
./scripts/create_configtxfileTemplate.sh

#exit 1
if [ $ORDERER_FLAG == "true" ];then
    sedOrderer
fi

sedOrgs
if [[ $ORDERER_FLAG == "false" && $NUMBER_OF_PEER_ORGS -eq 1 ]];then
    ORG_NAME="ORGANIZATION${NUMBER_OF_PEER_ORGS}_NAME"
    mv templates/configtx_template.yaml configtx_${!ORG_NAME}.yaml
else
    mv templates/configtx_template.yaml configtx.yaml
fi    
echo " ########### Finished creating configtx.yaml file #############"
    # else    
    #     sed -e 's/orderer_organization_name/'$NAME_OF_ORDERER_ORGANIZATION'/g' \
    #     -e 's/organization1_name/'$ORGANIZATION1_NAME'/g' \
    #     -e 's/orderer_organization_domain/'$DOMAIN_OF_ORDERER_ORGANIZATION'/g' \
    #     -e 's/organization1_domain/'$DOMAIN_OF_ORGANIZATION1'/g' \
    #     -e 's/organization_small_name/'$ORGANIZATION_NAME_LOWERCASE'/g' \
    #     -e 's/org1_anchorpeer_address/'$ORG1_ANCHOR_PEER'/g' \
    #     -e 's/orderer1_address/'$ORDERER1_ADDRESS'/g' \
    #     -e 's/orderer2_address/'$ORDERER2_ADDRESS'/g' \
    #     -e 's/orderer3_address/'$ORDERER3_ADDRESS'/g' templates/single/configtx_single_org_template.yaml > configtx.yaml
    # fi

    
