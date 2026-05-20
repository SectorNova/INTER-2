
echo "=================================================="
echo "STEP 1 : SYSTEM UPDATE"
echo "=================================================="

sudo apt update -y
sudo apt install -y --fix-missing


echo "=================================================="
echo "STEP 2 : BASIC PACKAGES INSTALLATION"
echo "=================================================="

sudo apt install -y curl git wget jq tar build-essential ca-certificates software-properties-common gnupg lsb-release


echo "=================================================="
echo "STEP 3 : INSTALL GO LANGUAGE"
echo "=================================================="

wget https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

echo "GO VERSION CHECK"
go version


echo "=================================================="
echo "STEP 4 : INSTALL DOCKER"
echo "=================================================="

sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

echo "DOCKER VERSION CHECK"
docker --version


echo "=================================================="
echo "STEP 5 : INSTALL NODEJS"
echo "=================================================="

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "NODE VERSION CHECK"
node -v

echo "NPM VERSION CHECK"
npm -v


echo "=================================================="
echo "STEP 6 : INSTALL JAVA (FABRIC COMPATIBLE)"
echo "=================================================="

sudo apt install -y openjdk-17-jdk

echo "JAVA VERSION CHECK"
java -version


echo "=================================================="
echo "STEP 7 : INSTALL TRUFFLE & GANACHE"
echo "=================================================="

sudo npm install -g truffle
sudo npm install -g ganache

echo "TRUFFLE VERSION CHECK"
truffle version


echo "=================================================="
echo "STEP 8 : INSTALL HYPERLEDGER FABRIC"
echo "=================================================="

curl -sSL https://bit.ly/2ysbOFE | bash -s


echo "=================================================="
echo "STEP 9 : START FABRIC NETWORK"
echo "=================================================="

cd ~/fabric-samples/test-network

./network.sh down
./network.sh up createChannel -ca


echo "=================================================="
echo "STEP 10 : DEPLOY CHAINCODE"
echo "=================================================="

./network.sh deployCC \
-ccn basic \
-ccp ../asset-transfer-basic/chaincode-go \
-ccl go


echo "=================================================="
echo "STEP 11 : START GANACHE BLOCKCHAIN"
echo "=================================================="

nohup ganache --host 0.0.0.0 --port 8545 > ganache.log 2>&1 &

sleep 5

echo "GANACHE STARTED SUCCESSFULLY"

echo "========== GANACHE ACCOUNTS =========="
cat ganache.log
echo "======================================="


echo "=================================================="
echo "STEP 12 : FINAL VERIFICATION"
echo "=================================================="

echo "GO VERSION"
go version

echo "DOCKER VERSION"
docker --version

echo "NODE VERSION"
node -v

echo "NPM VERSION"
npm -v

echo "JAVA VERSION"
java -version

echo "TRUFFLE VERSION"
truffle version

echo "DOCKER RUNNING CONTAINERS"
docker ps

echo "GANACHE PROCESS CHECK"
ps aux | grep ganache | grep -v grep


echo "=================================================="
echo "BLOCKCHAIN PRACTICAL COMPLETED SUCCESSFULLY"
echo "=================================================="
