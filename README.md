## Running the test network

You can use the `./network.sh up -ca` script to stand up a simple Fabric test network. Please edit `.env` file to decide the **#of orderer nodes**, **# of Organization(excluding OrdererOrg)**, **# of peers per node** you want to run. it requires **sudo** permission couple of times because when using `fabric-ca` then it changes the file permission hence require `sudo` access. You can also use the `./network.sh` script to create channels and deploy the fabcar chaincode. You can use `./network down` to remove the network. Use `./network.sh restart` to restart the network. For more information, see [Using the Fabric test network](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html). The test network is being introduced in Fabric v2.0 as the long term replacement for the `first-network` sample.

Before you can deploy the test network, you need to follow the instructions to [Install the Samples, Binaries and Docker Images](https://hyperledger-fabric.readthedocs.io/en/latest/install.html) in the Hyperledger Fabric documentation.

**TODO**
Proper documentation
need to fix some issues

**Based on github.com/hyperledger/fabric-samples/test-network**
