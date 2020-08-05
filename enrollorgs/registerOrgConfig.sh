#set -ev
#!/bin/sh

# Taking Inputs from .env file
set -a
[ -f .env ] && . .env
set +a


for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
  echo "##########################################################"
  echo "############ Create Org$ORG Identities ###################"
  echo "##########################################################"

  NAME_OF_ORGANIZATION="ORGANIZATION${ORG}_NAME"
  COMPANY_DOMAIN="DOMAIN_OF_ORGANIZATION${ORG}"
  ORG_CA_PORT="ORG${ORG}_PORT_NUMBER"

  echo
  echo "## Value of NAME_OF_ORGANIZATION is: ${!NAME_OF_ORGANIZATION}"
  echo "## Value of COMPANY_DOMAIN is: ${!COMPANY_DOMAIN}"
  echo "## Value of ORG_CA_PORT is: ${!ORG_CA_PORT}"

  echo
  echo "Enroll the CA admin"
  echo

  # when starting the docker container for CA then the generated crypto-config directory owner is set to root hence not able to 
  # create any directory in it without using sudo. hence once the crypto-config dir is created, we are changing the crypto-config
  # dir owner to current user. this requires sudo permission
  id=$(eval id -u)
  sudo chown $id:${id} -R crypto-config
  mkdir -p crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/
  export TLS_CERT_FILE=${PWD}/crypto-config/fabric-ca/${!COMPANY_DOMAIN}/tls-cert.pem
  export ORG_CA_URL=ca.${!COMPANY_DOMAIN}:${!ORG_CA_PORT}

  echo "######### Value of NAME_OF_ORGANIZATION is: ${!NAME_OF_ORGANIZATION}"
  echo "######### Value of COMPANY_DOMAIN is: ${!COMPANY_DOMAIN}"
  echo "######### Value of ORG_CA_PORT is: ${!ORG_CA_PORT}"
  echo "######### Value of FABRIC_CA_CLIENT_HOME is: $FABRIC_CA_CLIENT_HOME"
  echo "######### Value of TLS_CERT_FILE is: $TLS_CERT_FILE"
  echo "######### Value of ORG_CA_URL is: $ORG_CA_URL"
  echo
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  #admin:adminpw@localhost:7054
  fabric-ca-client enroll -u https://admin:adminpw@$ORG_CA_URL --caname ca.${!COMPANY_DOMAIN} --tls.certfiles $TLS_CERT_FILE
  set +x

  set -x
  echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
      Certificate: cacerts/ca.'${!COMPANY_DOMAIN}'-cert.pem
      OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
      Certificate: cacerts/ca.'${!COMPANY_DOMAIN}'-cert.pem
      OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
      Certificate: cacerts/ca.'${!COMPANY_DOMAIN}'-cert.pem
      OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
      Certificate: cacerts/ca.'${!COMPANY_DOMAIN}'-cert.pem
      OrganizationalUnitIdentifier: orderer' > ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/msp/config.yaml
  set +x
  
  echo
  echo "## Total number of peers per org $NUMBER_OF_PEER_NODES_PER_ORG"
  echo
  for PEER in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
    echo
    echo "Register peer$PEER.${!COMPANY_DOMAIN}"
    echo
    set -x
    fabric-ca-client register --caname ca.${!COMPANY_DOMAIN} --id.name peer$PEER.${!COMPANY_DOMAIN} --id.secret peer${PEER}pw --id.type peer --tls.certfiles $TLS_CERT_FILE
    set +x
  done

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca.${!COMPANY_DOMAIN} --id.name user1.${!COMPANY_DOMAIN} --id.secret user1pw --id.type client --tls.certfiles $TLS_CERT_FILE
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca.${!COMPANY_DOMAIN} --id.name admin.${!COMPANY_DOMAIN} --id.secret org1adminpw --id.type admin --tls.certfiles $TLS_CERT_FILE
  set +x

  set -x
  mkdir -p crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers
  set +x
  echo
  set -x
  mkdir ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/msp/tlscacerts
  set +x
  echo
  set -x
  mkdir ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/tlsca
  set +x
  echo
  set -x
  mkdir ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/ca
  set +x
  echo
  set -x
  mkdir -p crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users
  set +x
  echo
  set -x
  mkdir -p crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/User1.${!COMPANY_DOMAIN}
  set +x
  echo
  set -x
  mkdir -p crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/Admin.${!COMPANY_DOMAIN}
  set +x
  echo

  for PEER in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
    set -x
    mkdir -p crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}
    set +x
    
    echo
    echo "## Generate the peer$PEER.${!COMPANY_DOMAIN} msp"
    echo
    set -x
    fabric-ca-client enroll -u https://peer$PEER.${!COMPANY_DOMAIN}:peer${PEER}pw@$ORG_CA_URL --caname ca.${!COMPANY_DOMAIN} -M ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/msp --csr.hosts peer$PEER.${!COMPANY_DOMAIN} --tls.certfiles $TLS_CERT_FILE
    set +x

    cp ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/msp/config.yaml

    echo
    echo "## Generate the peer$PEER-tls certificates"
    echo
    set -x
    fabric-ca-client enroll -u https://peer$PEER.${!COMPANY_DOMAIN}:peer${PEER}pw@$ORG_CA_URL --caname ca.${!COMPANY_DOMAIN} -M ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls --enrollment.profile tls --csr.hosts peer$PEER.${!COMPANY_DOMAIN} --csr.hosts localhost --csr.hosts "127.0.0.1" --tls.certfiles $TLS_CERT_FILE
    set +x

    echo
    echo "## Moving and Renaming TLS certificates for peer$PEER.${!COMPANY_DOMAIN}"
    echo
    set -x
    cp ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/ca.crt
    set +x
    echo
    set -x
    cp ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/signcerts/* ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/server.crt
    set +x
    echo
    set -x
    cp ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/keystore/* ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/server.key
    set +x
    echo
    set -x
    cp ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/msp/tlscacerts/ca.crt
    set +x
    echo
    set -x
    cp ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/tlsca/tlsca.${!COMPANY_DOMAIN}-cert.pem
    set +x
    echo
    set -x
    cp ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/msp/cacerts/* ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/ca/ca.${!COMPANY_DOMAIN}-cert.pem
    set +x
    echo
    # renaming the cert names 
    set -x
    mv ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/msp/cacerts/*.pem ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/msp/cacerts/ca.${!COMPANY_DOMAIN}-cert.pem
    set +x

    # removing redundant directories
    set -x
    rm -rf ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/tls/{cacerts,tlscacerts,signcerts,keystore,user}
    set +x
    # create admincerts dir <-- temporary solution because NodeOU isn't working
    #mkdir ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/peers/peer$PEER.${!COMPANY_DOMAIN}/msp/admincerts
  done

  echo
  echo "## Generate the user1.${!COMPANY_DOMAIN} msp"
  echo
  set -x
  fabric-ca-client enroll -u https://user1.${!COMPANY_DOMAIN}:user1pw@$ORG_CA_URL --caname ca.${!COMPANY_DOMAIN} -M ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/User1.${!COMPANY_DOMAIN}/msp --tls.certfiles $TLS_CERT_FILE
  set +x

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
  fabric-ca-client enroll -u https://admin.${!COMPANY_DOMAIN}:org1adminpw@$ORG_CA_URL --caname ca.${!COMPANY_DOMAIN} -M ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/Admin.${!COMPANY_DOMAIN}/msp --tls.certfiles $TLS_CERT_FILE
  set +x

  set -x
  cp ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/Admin.${!COMPANY_DOMAIN}/msp/config.yaml
  set +x
  echo
  # renaming the cert names 
  ## renaming org/msp/cacerts
  set -x
  mv ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/msp/cacerts/*.pem ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/msp/cacerts/ca.${!COMPANY_DOMAIN}-cert.pem
  set +x
  echo
  ## renaming org/user/Admin/msp/cacerts
  set -x
  mv ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/Admin.${!COMPANY_DOMAIN}/msp/cacerts/*.pem ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/Admin.${!COMPANY_DOMAIN}/msp/cacerts/ca.${!COMPANY_DOMAIN}-cert.pem
  set +x
  echo
  ## renaming org/users/User/msp/ca/certs
  set -x
  mv ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/User1.${!COMPANY_DOMAIN}/msp/cacerts/*.pem ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/users/User1.${!COMPANY_DOMAIN}/msp/cacerts/ca.${!COMPANY_DOMAIN}-cert.pem
  set +x
  echo
  # create admincerts dir <-- temporary solution because NodeOU isn't working
  #mkdir ${PWD}/crypto-config/peerOrganizations/${!COMPANY_DOMAIN}/msp/admincerts
done