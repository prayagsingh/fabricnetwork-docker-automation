#!/bin/bash
#
# Reading some variables from .env file
set -a
[ -f .env ] && . .env
set +a


docker exec cli-peer1-beta.com peer channel create -o orderer1.alpha.com:7050 -c mychannel --ordererTLSHostnameOverride orderer1.alpha.com -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/mychannel.tx --outputBlock ./channel-artifacts/mychannel.block --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/alpha.com/orderers/orderer1.alpha.com/msp/tlscacerts/tlsca.alpha.com-cert.pem

docker exec cli-peer1-beta.com peer channel join -b ./channel-artifacts/mychannel.block
docker exec cli-peer2-beta.com peer channel join -b ./channel-artifacts/mychannel.block
docker exec cli-peer1-gamma.com peer channel join -b ./channel-artifacts/mychannel.block
docker exec cli-peer2-gamma.com peer channel join -b ./channel-artifacts/mychannel.block