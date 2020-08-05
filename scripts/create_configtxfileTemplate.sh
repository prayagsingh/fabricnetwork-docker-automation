#!/bin/bash
#

# Reading some variables from .env file
set -a
[ -f .env ] && . .env
set +a

pwd

echo -n "Organizations:" > ./templates/configtx_template.yaml

if [ $ORDERER_FLAG == "true" ];then
echo -n "
    - &orderer_organization_name
        Name: orderer_organization_name
        ID: orderer_organization_nameMSP
        MSPDir: crypto-config/ordererOrganizations/orderer_organization_domain/msp
        Policies:
            Readers:
                Type: Signature
                Rule: \"OR('orderer_organization_nameMSP.member')\"
            Writers:
                Type: Signature
                Rule: \"OR('orderer_organization_nameMSP.member')\"
            Admins:
                Type: Signature
                Rule: \"OR('orderer_organization_nameMSP.admin')\"

        OrdererEndpoints:
            - orderer1_address:7050
            - orderer2_address:8050
            - orderer3_address:9050
" >> ./templates/configtx_template.yaml
fi

for org in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
echo -n "   
    - &organization${org}_name
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: organization${org}_name

        # ID to load the MSP definition as
        ID: organization${org}_nameMSP

        MSPDir: crypto-config/peerOrganizations/organization${org}_domain/msp

        # Policies defines the set of policies at this level of the config tree
        # For organization policies, their canonical path is usually
        #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
        Policies:
            Readers:
                Type: Signature
                Rule: \"OR('organization${org}_nameMSP.admin', 'organization${org}_nameMSP.peer', 'organization${org}_nameMSP.client')\"
            Writers:
                Type: Signature
                Rule: \"OR('organization${org}_nameMSP.admin', 'organization${org}_nameMSP.client')\"
            Admins:
                Type: Signature
                Rule: \"OR('organization${org}_nameMSP.admin')\"
            Endorsement:    
                Type: Signature
                Rule: \"OR('organization${org}_nameMSP.peer')\"

        # leave this flag set to true.
        AnchorPeers:
            # AnchorPeers defines the location of peers which can be used
            # for cross org gossip communication.  Note, this value is only
            # encoded in the genesis block in the Application section context
            - Host: org${org}_anchorpeer_address
              Port: org${org}_anchor_peer_port
" >> ./templates/configtx_template.yaml

done

if [ $ORDERER_FLAG == "true" ];then
echo -n "
Capabilities:
    # Channel capabilities apply to both the orderers and the peers and must be
    # supported by both.
    # Set the value of the capability to true to require it.
    Channel: &ChannelCapabilities
        V2_0: true

    # Orderer capabilities apply only to the orderers, and may be safely
    # used with prior release peers.
    # Set the value of the capability to true to require it.
    Orderer: &OrdererCapabilities
        V2_0: true

    # Application capabilities apply only to the peer network, and may be safely
    # used with prior release orderers.
    # Set the value of the capability to true to require it.
    Application: &ApplicationCapabilities
        V2_0: true

Application: &ApplicationDefaults

    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:

    # Policies defines the set of policies at this level of the config tree
    # For Application policies, their canonical path is
    #   /Channel/Application/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: \"ANY Readers\"
        Writers:
            Type: ImplicitMeta
            Rule: \"ANY Writers\"
        Admins:
            Type: ImplicitMeta
            Rule: \"ANY Admins\"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: \"MAJORITY Endorsement\"
        Endorsement:
            Type: ImplicitMeta
            Rule: \"MAJORITY Endorsement\"

    Capabilities:
        <<: *ApplicationCapabilities        
" >> ./templates/configtx_template.yaml

echo -n '
Orderer: &OrdererDefaults
    Addresses:
        - orderer1_address:7050
        - orderer2_address:8050
        - orderer3_address:9050 
        
    OrdererType: etcdraft
    EtcdRaft:
        Consenters:
        - Host: orderer1_address
          Port: 7050
          ClientTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer1.orderer_organization_domain/tls/server.crt
          ServerTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer1.orderer_organization_domain/tls/server.crt
        - Host: orderer2_address
          Port: 8050
          ClientTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer2.orderer_organization_domain/tls/server.crt
          ServerTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer2.orderer_organization_domain/tls/server.crt
        - Host: orderer3_address
          Port: 9050
          ClientTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer3.orderer_organization_domain/tls/server.crt
          ServerTLSCert: crypto-config/ordererOrganizations/orderer_organization_domain/orderers/orderer3.orderer_organization_domain/tls/server.crt      
    
        # Options to be specified for all the etcd/raft nodes. The values here
        # are the defaults for all new channels and can be modified on a
        # per-channel basis via configuration updates.
        Options:
            # TickInterval is the time interval between two Node.Tick invocations.
            TickInterval: 500ms

            # ElectionTick is the number of Node.Tick invocations that must pass
            # between elections. That is, if a follower does not receive any
            # message from the leader of current term before ElectionTick has
            # elapsed, it will become candidate and start an election.
            # ElectionTick must be greater than HeartbeatTick.
            ElectionTick: 10

            # HeartbeatTick is the number of Node.Tick invocations that must
            # pass between heartbeats. That is, a leader sends heartbeat
            # messages to maintain its leadership every HeartbeatTick ticks.
            HeartbeatTick: 1

            # MaxInflightBlocks limits the max number of in-flight append messages
            # during optimistic replication phase.
            MaxInflightBlocks: 5

            # SnapshotIntervalSize defines number of bytes per which a snapshot is taken
            SnapshotIntervalSize: 20 MB 
    # Batch Timeout: The amount of time to wait before creating a batch/block
    BatchTimeout: 2s
    # Batch Size: Controls the number of messages batched into a block
    BatchSize:
        # Max Message Count: The maximum number of messages to permit in a batch
        MaxMessageCount: 10
        # Absolute Max Bytes: The absolute maximum number of bytes allowed for
        # the serialized messages in a batch.
        AbsoluteMaxBytes: 99 MB
        # Preferred Max Bytes: The preferred maximum number of bytes allowed for
        # the serialized messages in a batch. A message larger than the preferred
        # max bytes will result in a batch larger than preferred max bytes.
        PreferredMaxBytes: 512 KB
    
    # Organizations is the list of orgs which are defined as participants on
    # the orderer side of the network
    Organizations:

    # Policies defines the set of policies at this level of the config tree
    # For Orderer policies, their canonical path is
    #   /Channel/Orderer/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "ANY Admins"
        BlockValidation:
            Type: ImplicitMeta
            Rule: "ANY Writers"

' >> ./templates/configtx_template.yaml

echo -n '
Channel: &ChannelDefaults
    # Policies defines the set of policies at this level of the config tree
    # For Channel policies, their canonical path is
    #   /Channel/<PolicyName>
    Policies:
        # Who may invoke the "Deliver" API
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        # Who may invoke the "Broadcast" API
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        # By default, who may modify elements at this config level
        Admins:
            Type: ImplicitMeta
            Rule: "ANY Admins"

    Capabilities:
        <<: *ChannelCapabilities

' >> ./templates/configtx_template.yaml
echo -n '
Profiles:
    TwoOrgsOrdererGenesis:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *orderer_organization_name
            Capabilities:
                <<: *OrdererCapabilities    
        Consortiums:
            SampleConsortium:
                Organizations:
' >> ./templates/configtx_template.yaml

for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
echo -n "
                  - *organization${ORG}_name
"  | sed '/^[[:space:]]*$/d' >> ./templates/configtx_template.yaml
done

echo -n '
    TwoOrgsChannel:
        Consortium: SampleConsortium
        <<: *ChannelDefaults
        Application:
            <<: *ApplicationDefaults
            Organizations:
' >> ./templates/configtx_template.yaml

for ORG in $(seq 1 "$NUMBER_OF_PEER_ORGS"); do
echo -n "
              - *organization${ORG}_name
" | sed '/^[[:space:]]*$/d' >> ./templates/configtx_template.yaml
done

echo -n "
        Capabilities:
            <<: *ApplicationCapabilities
" >> ./templates/configtx_template.yaml
fi