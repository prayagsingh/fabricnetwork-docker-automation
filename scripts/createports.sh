#set -ev
#!/bin/bash

# Reagin env variables
set -a
[ -f .env ] && . .env
set +a


## Creating ports for dev mode
function createPorts(){
    PEER_LISTEN_PORT=6051
    PEER_CC_LISTEN_PORT=6052
    PEER_OPERATION_PORT=6443
    COUCHDB_PORT=4984
    for org in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do 
        #echo "Looping for org$org"
        for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
          #echo "Looping for peer$peer"
          PLP=`expr $peer \* 1000` # 2*1000
          #echo $PLP
          export ORG${org}_PEER${peer}_LISTEN_PORT=`expr $PEER_LISTEN_PORT + $PLP`
          export ORG${org}_PEER${peer}_CC_LISTEN_PORT=`expr $PEER_CC_LISTEN_PORT + $PLP`
          export ORG${org}_PEER${peer}_OPERATION_PORT=`expr $PEER_OPERATION_PORT + $PLP`
          export ORG${org}_PEER${peer}_COUCHDB_PORT=`expr $COUCHDB_PORT + $PLP`

          p1="ORG${org}_PEER${peer}_LISTEN_PORT"
          p2="ORG${org}_PEER${peer}_CC_LISTEN_PORT"
          p3="ORG${org}_PEER${peer}_OPERATION_PORT"
          p4="ORG${org}_PEER${peer}_COUCHDB_PORT"

        done

        PEER_LISTEN_PORT=${!p1}
        PEER_CC_LISTEN_PORT=${!p2}
        PEER_OPERATION_PORT=${!p3}
        COUCHDB_PORT=${!p4}    
    done    
}