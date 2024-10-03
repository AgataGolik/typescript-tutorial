#!/bin/bash

show() {
    echo
    echo -e "\e[1;35m$1\e[0m"
    echo
}

if ! [ -x "$(command -v git)" ]; then
    show "Git is not installed. Installing git..."
    sudo apt-get update && sudo apt-get install git -y
else
    show "Git is already installed."
fi

show "Installing npm..."
source <(wget -O - https://raw.githubusercontent.com/AgataGolik/installationnew/main/node.sh)

if [ -d "Story-Protocol" ]; then
    show "Removing existing Story directory..."
    rm -rf Story-Protocol
fi

show "Cloning Story repository..."
git clone https://github.com/AgataGolik/typescript-tutorial.git && cd typescript-tutorial

show "Installing npm dependencies..."
npm install
echo

read -p "Enter your wallet private key: " WALLET
read -p "Enter Pinata JWT token: " JWT


cat <<EOF > .env
WALLET_PRIVATE_KEY=$WALLET
PINATA_JWT=$JWT
RPC_PROVIDER_URL=https://testnet.storyrpc.io
EOF


show "Running npm script to create SPG collection..."
npm run create-spg-collection
echo

read -p "Enter NFT contract address: " CONTRACT
echo

echo "NFT_CONTRACT_ADDRESS=$CONTRACT" >> .env

show "Running npm script for metadata..."
npm run metadata
echo
