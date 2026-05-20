#!/usr/bin/env bash

echo "===================================="
echo " BLOCKCHAIN PRACTICAL SETUP (FINAL)"
echo "===================================="

# Step 1: FULL CLEAN (important)
rm -rf ~/blockchain-exp3
mkdir -p ~/blockchain-exp3
cd ~/blockchain-exp3 

# Step 2: Check Node
node -v || { echo "Node not installed"; exit 1; }
npm -v || { echo "npm not installed"; exit 1; }

# Step 3: Init project
npm init -y >/dev/null

# Step 4: 🔥 FORCE EXACT VERSION + COMMONJS MODE
npm pkg set type="commonjs" >/dev/null

echo "Installing stable Web3 v1.10.0..."
npm install web3@1.10.0 ganache --save --force >/dev/null 2>&1

# Step 5: VERIFY VERSION (debug safety)
echo "Installed Web3 version:"
npm list web3

# Step 6: Ganache server
cat > server.sh <<'EOF'
#!/usr/bin/env bash
echo "===================================="
echo " STARTING GANACHE SERVER"
echo "===================================="

npx ganache \
  --server.port 8545 \
  --wallet.totalAccounts 2 \
  --wallet.defaultBalance 1000 \
  --chain.chainId 1337
EOF

chmod +x server.sh

# Step 7: 🔥 STRICT v1 SYNTAX app.js (NO MIXED EXPORTS)
cat > app.js <<'EOF'
const Web3 = require("web3");   // PURE v1 import

async function main() {
  const web3 = new Web3("http://127.0.0.1:8545");

  const accounts = await web3.eth.getAccounts();
  console.log("Accounts:", accounts);

  const bal1 = await web3.eth.getBalance(accounts[0]);
  console.log("Sender Balance:", web3.utils.fromWei(bal1, "ether"));

  const tx = await web3.eth.sendTransaction({
    from: accounts[0],
    to: accounts[1],
    value: web3.utils.toWei("2", "ether")
  });

  console.log("Tx Hash:", tx.transactionHash);
}

main().catch(console.error);
EOF

chmod +x app.js

echo "===================================="
echo " ✅ SETUP COMPLETED SUCCESSFULLY"
echo "===================================="
echo "STEP 1: Terminal 1 → bash server.sh"
echo "STEP 2: Terminal 2 → node app.js"
echo "===================================="
