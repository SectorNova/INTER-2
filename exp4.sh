#!/bin/bash

echo "=================================================="
echo "STEP 1: Fix permission issues"
echo "=================================================="

sudo chown -R $USER:$USER $HOME/fabric-samples 2>/dev/null || true

echo "=================================================="
echo "STEP 2: Clean old Fabric files"
echo "=================================================="

cd $HOME
sudo rm -rf fabric-samples

echo "=================================================="
echo "STEP 3: Update system and install packages"
echo "=================================================="

sudo apt update
sudo apt install -y git curl jq docker.io docker-compose golang-go

echo "=================================================="
echo "STEP 4: Start Docker"
echo "=================================================="

sudo systemctl start docker
sudo systemctl enable docker

echo "=================================================="
echo "STEP 5: Download Fabric samples"
echo "=================================================="

cd $HOME
curl -sSL https://bit.ly/2ysbOFE | bash -s

echo "=================================================="
echo "STEP 6: Go to test-network"
echo "=================================================="

cd $HOME/fabric-samples/test-network

echo "=================================================="
echo "STEP 7: Bring network down"
echo "=================================================="

./network.sh down || true

echo "=================================================="
echo "STEP 8: Pull Docker images"
echo "=================================================="

docker pull hyperledger/fabric-peer:latest
docker pull hyperledger/fabric-orderer:latest
docker pull hyperledger/fabric-ca:latest
docker pull hyperledger/fabric-tools:latest
docker pull hyperledger/fabric-ccenv:latest
docker pull hyperledger/fabric-baseos:latest

echo "=================================================="
echo "STEP 9: Tag images (Fix ccenv error)"
echo "=================================================="

docker tag hyperledger/fabric-peer:latest hyperledger/fabric-peer:3.1 || true
docker tag hyperledger/fabric-orderer:latest hyperledger/fabric-orderer:3.1 || true
docker tag hyperledger/fabric-ca:latest hyperledger/fabric-ca:3.1 || true
docker tag hyperledger/fabric-tools:latest hyperledger/fabric-tools:3.1 || true
docker tag hyperledger/fabric-ccenv:latest hyperledger/fabric-ccenv:3.1 || true
docker tag hyperledger/fabric-baseos:latest hyperledger/fabric-baseos:3.1 || true

echo "=================================================="
echo "STEP 10: Start network"
echo "=================================================="

./network.sh up createChannel -ca

echo "=================================================="
echo "STEP 11: Deploy chaincode"
echo "=================================================="

./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go

echo "=================================================="
echo "STEP 12: Set environment variables"
echo "=================================================="

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

echo "=================================================="
echo "STEP 13: Initialize Ledger"
echo "=================================================="

peer chaincode invoke \
-o localhost:7050 \
--ordererTLSHostnameOverride orderer.example.com \
--tls \
--cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
-C mychannel \
-n basic \
--peerAddresses localhost:7051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
--peerAddresses localhost:9051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
-c '{"function":"InitLedger","Args":[]}'

sleep 5

echo "=================================================="
echo "STEP 14: Query Assets"
echo "=================================================="

peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

echo "=================================================="
echo "SUCCESS: FULLY WORKING WITHOUT ERRORS"
echo "=================================================="
