#!/bin/bash
#

# Reading some variables from .env file
set -a
[ -f .env ] && . .env
set +a

pwd

echo 
echo " Creating ccp-template.yaml file"
echo 

echo -n "
name: testnetwork-\${ORG_NAME}
version: 1.0.0
client:
  organization: \${ORG_NAME}
  connection:
    timeout:
      peer:
        endorser: '300'
organizations:
  \${ORG_NAME}:
    mspid: \${ORG_NAME}MSP
    peers:
" > ./templates/ccp-template.yaml

for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
echo -n "
    - peer${peer}.\${ORG_DOMAIN}
" | sed '/^[[:space:]]*$/d' >> ./templates/ccp-template.yaml
done

echo "
    certificateAuthorities:
    - ca.\${ORG_DOMAIN}
" >> ./templates/ccp-template.yaml

echo -n "peers:" >> ./templates/ccp-template.yaml

for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
echo -n "
  peer${peer}.\${ORG_DOMAIN}:
    url: grpcs://peer${peer}.\${ORG_DOMAIN}:\${P${peer}PORT}
    tlsCACerts:
      pem: |
        \${PEERPEM}
    grpcOptions:
      ssl-target-name-override: peer${peer}.\${ORG_DOMAIN}
      hostnameOverride: peer${peer}.\${ORG_DOMAIN}
" >> ./templates/ccp-template.yaml
done

echo "
certificateAuthorities:
  ca.\${ORG_DOMAIN}:
    url: https://ca.\${ORG_DOMAIN}:\${CAPORT}
    caName: ca.\${ORG_DOMAIN}
    tlsCACerts:
      pem: |
        \${CAPEM}
    httpOptions:
      verify: false
" >> ./templates/ccp-template.yaml

########################################################
########################################################
echo 
echo " Creating ccp-template.json file"
echo 

echo '
{
    "name": "testnetwork-${ORG_NAME}",
    "version": "1.0.0",
    "client": {
        "organization": "${ORG_NAME}",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300"
                }
            }
        }
    },
    "organizations": {
        "${ORG_NAME}": {
            "mspid": "${ORG_NAME}MSP",
            "peers": [
' > templates/ccp-template.json

for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
if [[ $NUMBER_OF_PEER_NODES_PER_ORG -eq 1 || $peer -eq $NUMBER_OF_PEER_NODES_PER_ORG ]]; then
echo -n " 
                \"peer${peer}.\${ORG_DOMAIN}\"
" | sed '/^[[:space:]]*$/d' >> ./templates/ccp-template.json
else
echo -n " 
                \"peer${peer}.\${ORG_DOMAIN}\",
" | sed '/^[[:space:]]*$/d' >> ./templates/ccp-template.json
fi
done

echo -n '
            ]
        }
    },
    "peers": {
' >> templates/ccp-template.json

for peer in $(seq 1 "$NUMBER_OF_PEER_NODES_PER_ORG"); do
if [[ $NUMBER_OF_PEER_NODES_PER_ORG -eq 1 || $peer -eq $NUMBER_OF_PEER_NODES_PER_ORG ]]; then 
echo -n "
        \"peer${peer}.\${ORG_DOMAIN}\": {
            \"url\": \"grpcs://peer${peer}.\${ORG_DOMAIN}:\${P${peer}PORT}\",
            \"tlsCACerts\": {
                \"pem\": \"\${PEERPEM}\"
            },
            \"grpcOptions\": {
                \"ssl-target-name-override\": \"peer${peer}.\${ORG_DOMAIN}\",
                \"hostnameOverride\": \"peer${peer}.\${ORG_DOMAIN}\"
            }
        }

" | sed '/^[[:space:]]*$/d' >> ./templates/ccp-template.json
else
echo -n "
        \"peer${peer}.\${ORG_DOMAIN}\": {
            \"url\": \"grpcs://peer${peer}.\${ORG_DOMAIN}:\${P${peer}PORT}\",
            \"tlsCACerts\": {
                \"pem\": \"\${PEERPEM}\"
            },
            \"grpcOptions\": {
                \"ssl-target-name-override\": \"peer${peer}.\${ORG_DOMAIN}\",
                \"hostnameOverride\": \"peer${peer}.\${ORG_DOMAIN}\"
            }
        },

" | sed '/^[[:space:]]*$/d' >> ./templates/ccp-template.json
fi
done

echo -n '
    },
    "certificateAuthorities": {
        "ca.${ORG_DOMAIN}": {
            "url": "https://ca.${ORG_DOMAIN}:${CAPORT}",
            "caName": "ca.${ORG_DOMAIN}",
            "tlsCACerts": {
                "pem": "${CAPEM}"
            },
            "httpOptions": {
                "verify": false
            }
        }
    }
}

' >> ./templates/ccp-template.json