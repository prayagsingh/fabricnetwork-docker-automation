#set -ev
#!/bin/sh

# Taking Inputs from .env file
set -a
[ -f .env ] && . .env
set +a

echo
echo "Enroll the ORDERER ORG CA admin"
echo
mkdir -p crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION

export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION
export TLS_CERT_FILE=${PWD}/crypto-config/fabric-ca/$DOMAIN_OF_ORDERER_ORGANIZATION/tls-cert.pem
export ORD_CA_URL=ca.$DOMAIN_OF_ORDERER_ORGANIZATION:$ORD_PORT_NUMBER

set -x
fabric-ca-client enroll -u https://admin:adminpw@$ORD_CA_URL --caname ca.$DOMAIN_OF_ORDERER_ORGANIZATION --tls.certfiles $TLS_CERT_FILE
set +x

echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.'$DOMAIN_OF_ORDERER_ORGANIZATION'-cert.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.'$DOMAIN_OF_ORDERER_ORGANIZATION'-cert.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.'$DOMAIN_OF_ORDERER_ORGANIZATION'-cert.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.'$DOMAIN_OF_ORDERER_ORGANIZATION'-cert.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/msp/config.yaml

for ORDERER in $(seq 1 "$NUMBER_OF_ORDERER_NODES"); do
  echo
  echo "Register orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION"
  echo
  set -x
  fabric-ca-client register --caname ca.$DOMAIN_OF_ORDERER_ORGANIZATION --id.name orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION --id.secret ordererpw --id.type orderer --tls.certfiles $TLS_CERT_FILE
  set +x
done

echo
echo "Register the orderer admin"
echo
set -x
fabric-ca-client register --caname ca.$DOMAIN_OF_ORDERER_ORGANIZATION --id.name Admin.$DOMAIN_OF_ORDERER_ORGANIZATION --id.secret ordererAdminpw --id.type admin --tls.certfiles $TLS_CERT_FILE
set +x

mkdir -p crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers
#mkdir -p crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/$DOMAIN_OF_ORDERER_ORGANIZATION
mkdir -p ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/msp/tlscacerts
mkdir -p crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/users

for ORDERER in $(seq 1 "$NUMBER_OF_ORDERER_NODES"); do
  mkdir -p crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION

  echo
  echo "## Enroll the orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION msp"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION:ordererpw@$ORD_CA_URL --caname ca.$DOMAIN_OF_ORDERER_ORGANIZATION -M ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/msp --csr.hosts orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION --csr.hosts localhost --csr.hosts "127.0.0.1" --tls.certfiles $TLS_CERT_FILE
  set +x

  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/config.yaml

  echo
  echo "## Enroll orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION:ordererpw@$ORD_CA_URL --caname ca.$DOMAIN_OF_ORDERER_ORGANIZATION -M ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls --enrollment.profile tls --csr.hosts orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION --csr.hosts localhost --csr.hosts "127.0.0.1" --tls.certfiles $TLS_CERT_FILE
  set +x

  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/ca.crt
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/signcerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/server.crt
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/keystore/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/server.key

  mkdir ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/tlscacerts
  cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/tlscacerts/tlsca.$DOMAIN_OF_ORDERER_ORGANIZATION-cert.pem

  # changin name of msp/cacerts
  mv ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/cacerts/*.pem ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/cacerts/ca.${DOMAIN_OF_ORDERER_ORGANIZATION}-cert.pem

  # removing redundant directories
  rm -rf ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/{cacerts,tlscacerts,signcerts,keystore,user}

  # creating admincerts directory because NodeOU isn't working. It is temporary solution
  #mkdir ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer$ORDERER.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/admincerts

done

# Copying tls-cert from orderer1/msp to orderer-org/msp
cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/orderers/orderer1.$DOMAIN_OF_ORDERER_ORGANIZATION/tls/ca.crt ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/msp/tlscacerts/tlsca.$DOMAIN_OF_ORDERER_ORGANIZATION-cert.pem

# changing cacerts name to decent one
mv ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/msp/cacerts/*.pem ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/msp/cacerts/ca.${DOMAIN_OF_ORDERER_ORGANIZATION}-cert.pem 

mkdir -p crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/users/Admin.$DOMAIN_OF_ORDERER_ORGANIZATION

# creating admincerts <-- temporary solution
#mkdir ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/msp/admincerts

echo
echo "## Enroll org admin cert and Generate the admin msp"
echo
set -x
fabric-ca-client enroll -u https://Admin.$DOMAIN_OF_ORDERER_ORGANIZATION:ordererAdminpw@$ORD_CA_URL --caname ca.$DOMAIN_OF_ORDERER_ORGANIZATION -M ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/users/Admin.$DOMAIN_OF_ORDERER_ORGANIZATION/msp --tls.certfiles $TLS_CERT_FILE
set +x

cp ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/users/Admin.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/config.yaml
mv ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/users/Admin.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/cacerts/*.pem ${PWD}/crypto-config/ordererOrganizations/$DOMAIN_OF_ORDERER_ORGANIZATION/users/Admin.$DOMAIN_OF_ORDERER_ORGANIZATION/msp/cacerts/ca.${DOMAIN_OF_ORDERER_ORGANIZATION}-cert.pem 


