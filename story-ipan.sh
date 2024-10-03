#!/bin/bash

# Flaga pozwalająca na pominięcie setupu
SKIP_SETUP=false

# Sprawdzanie, czy została podana flaga --skip-setup
while [[ "$1" == --* ]]; do
    case "$1" in
        --skip-setup) SKIP_SETUP=true ;;
    esac
    shift
done

show() {
    echo
    echo -e "\e[1;35m$1\e[0m"
    echo
}

# Jeśli flaga skip-setup nie została ustawiona, wykonaj setup
if ! $SKIP_SETUP; then
    if ! [ -x "$(command -v git)" ]; then
        show "Git is not installed. Installing git..."
        sudo apt-get update && sudo apt-get install git -y
    else
        show "Git is already installed."
    fi

    show "Installing npm..."
    source <(wget -O - https://raw.githubusercontent.com/AgataGolik/installationnew/main/node.sh)

    if [ -d "typescript-tutorial" ]; then
        show "Removing existing typescript-tutorial directory..."
        rm -rf typescript-tutorial
    fi

    show "Cloning Story repository..."
    git clone https://github.com/AgataGolik/typescript-tutorial.git && cd typescript-tutorial

    show "Installing npm dependencies..."
    npm install
else
    show "Setup skipped. Continuing with the process..."
fi

run_creation_process() {
    echo
    read -p "Enter your wallet private key: " WALLET
    read -p "Enter Pinata JWT token: " JWT
    read -p "Enter custom title for NFT: " CUSTOM_TITLE
    read -p "Enter custom name for NFT: " CUSTOM_NAME
    read -p "Enter custom description for NFT: " CUSTOM_DESCRIPTION

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

    show "Modifying the TypeScript script..."
    sed -i "s/title: '.*',/title: '$CUSTOM_TITLE',/" scripts/metadataExample.ts
    sed -i "s/description: '.*',/description: '$CUSTOM_DESCRIPTION',/" scripts/metadataExample.ts
    sed -i "s/name: '.*',/name: '$CUSTOM_NAME',/" scripts/metadataExample.ts

    show "Running npm script for metadata..."
    npm run metadata
    echo

    show "Setup complete. Your custom metadata has been applied to the TypeScript script."

    # Usunięcie pliku .env po zakończeniu procesu
    rm -f .env
    show ".env file has been removed for security reasons."
}

run_creation_process

while true; do
    echo
    read -p "Do you want to repeat the process with new data? (Y/N): " REPEAT
    if [[ "$REPEAT" == "Y" || "$REPEAT" == "y" ]]; then
        run_creation_process
    else
        show "Process completed. Exiting..."
        break
    fi
done

unset WALLET_PRIVATE_KEY
unset PINATA_JWT
unset NFT_CONTRACT_ADDRESS
show "Environment variables have been cleared for security reasons."
