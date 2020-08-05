#set -ev
#!/bin/bash

set -a
[ -f .env ] && . .env
set +a

pwd
echo ""
echo " ##############################################################"
echo " ############# Creating docker CA file for Orgs ###############"
echo " ##############################################################"
echo ""

#echo "### Value of ORDERER_ORGANIZATION_NAME_LOWERCASE is: $ORDERER_ORGANIZATION_NAME_LOWERCASE"

if [ $ORDERER_FLAG == "true" ];then
    echo " ########### Creating a docker-orderer-ca.yaml file from template"
    ORDERER_ORGANIZATION_NAME_LOWERCASE=`echo "$NAME_OF_ORD_ORG" | tr '[:upper:]' '[:lower:]'`
    sed -e 's/organization_small_name/'$ORDERER_ORGANIZATION_NAME_LOWERCASE'/g' \
        -e 's/organization_domain/'$DOMAIN_OF_ORDERER_ORGANIZATION'/g' \
        -e 's/port_number/'$ORD_PORT_NUMBER'/g' templates/docker-compose-ca-template.yaml > ./docker/docker-compose-ca-orderer.yaml
fi 
# creating CA for
for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
    ORG_NAME="ORGANIZATION${ORG}_NAME"
    ORG_DOMAIN="DOMAIN_OF_ORGANIZATION${ORG}"
    PORT_NUMBER="ORG${ORG}_PORT_NUMBER"
    ORG_LOWERCASE=`echo "${!ORG_NAME}" | tr '[:upper:]' '[:lower:]'`
    
    echo "### value of ORG_NAME in CA is: ${!ORG_NAME}"
    echo "### value of ORG_DOMAIN in CA is: ${!ORG_DOMAIN}"
    echo "### value of PORT_NUMBER is: ${!PORT_NUMBER}"
    echo " ########### Creating docker-compose-ca-$ORG_LOWERCASE.yaml file from template"
    sed -e 's/organization_small_name/'$ORG_LOWERCASE'/g' \
        -e 's/organization_domain/'${!ORG_DOMAIN}'/g' \
        -e 's/port_number/'${!PORT_NUMBER}'/g' templates/docker-compose-ca-template.yaml > ./docker/docker-compose-ca-$ORG_LOWERCASE.yaml
    echo 
done
echo " ########### Creating Orderer and peer files"
#./sed_docker_files.sh $NETWORK_TYPE $DOMAIN_OF_ORDERER_ORGANIZATION $DOMAIN_OF_ORGANIZATION $ORGANIZATION1_NAME $ORDERER_FLAG
./sed_scripts/sed_docker_files.sh
echo 
