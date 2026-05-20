#!/bin/bash

echo "=================================================="
echo "BLOCKCHAIN JAVA SDK PRACTICAL - KALI / UBUNTU"
echo "CLEAN + SAFE + EXAM READY VERSION"
echo "=================================================="


echo "================ STEP 1 : SYSTEM UPDATE ================"
sudo apt update -y


echo "================ STEP 2 : INSTALL TOOLS ================"
sudo apt install -y git curl wget jq docker.io docker-compose maven


echo "================ STEP 3 : START DOCKER ================"
sudo systemctl start docker
sudo systemctl enable docker

echo "DOCKER VERSION"
docker --version


echo "================ STEP 4 : INSTALL NODEJS ================"
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "NODE VERSION"
node -v

echo "NPM VERSION"
npm -v


echo "================ STEP 5 : INSTALL JAVA (FABRIC COMPATIBLE) ================"
sudo apt install -y openjdk-17-jdk

echo "JAVA VERSION"
java -version


echo "================ STEP 6 : CLONE REPOSITORY ================"
git clone https://github.com/IBM/blockchain-application-using-fabric-java-sdk.git

cd blockchain-application-using-fabric-java-sdk/network


echo "================ STEP 7 : BUILD NETWORK ================"
chmod +x build.sh stop.sh teardown.sh

./stop.sh
./teardown.sh
./build.sh


echo "================ STEP 8 : DOCKER CLEANUP ================"
docker container prune -f
docker network prune -f
docker volume prune -f


echo "================ STEP 9 : MAVEN BUILD ================"
cd ../java

mvn clean install -DskipTests


echo "================ STEP 10 : COPY JAR FILE ================"
cd target

cp *jar-with-dependencies*.jar blockchain-client.jar
cp blockchain-client.jar ../../network_resources/


echo "================ STEP 11 : FABRIC OPERATIONS ================"
cd ../../network_resources

echo "---- CREATE CHANNEL ----"
java -cp blockchain-client.jar org.example.network.CreateChannel

echo "---- DEPLOY CHAINCODE ----"
java -cp blockchain-client.jar org.example.network.DeployInstantiateChaincode

echo "---- REGISTER USER ----"
java -cp blockchain-client.jar org.example.user.RegisterEnrollUser

echo "---- INVOKE CHAINCODE ----"
java -cp blockchain-client.jar org.example.chaincode.invocation.InvokeChaincode


echo "=================================================="
echo "BLOCKCHAIN PRACTICAL COMPLETED SUCCESSFULLY"
echo "=================================================="
