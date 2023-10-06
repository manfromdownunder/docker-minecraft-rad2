#!/bin/bash
set -e

# Check for file argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_file_with_urls>"
    exit 1
fi

FILE_PATH=$1

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create a directory for npm and puppeteer/chrome files
BINARY_DIR="$SCRIPT_DIR/binaries"
mkdir -p "$BINARY_DIR"

# Check if libnss3 library for ChromeDriver is installed
if ! dpkg -l | grep -q libnss3; then
    sudo apt-get update
    sudo apt-get install -y libnss3
fi

# Install Node.js and Puppeteer
(
    cd "$BINARY_DIR"
    if ! command -v node &>/dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        nvm install node
    else
        echo "Node.js is already installed."
    fi
    npm install puppeteer@12.0.1  --prefix "$BINARY_DIR"
    npm install puppeteer-extra puppeteer-extra-plugin-stealth
)

# Get Chromium executable path
export NODE_PATH="$BINARY_DIR/node_modules"
CHROME_PATH=$(node -e "const puppeteer = require('puppeteer'); console.log(puppeteer.executablePath());")
echo "Chromium path: $CHROME_PATH"

# Ensure puppeteer-extra is installed
if [ ! -d "$BINARY_DIR/node_modules/puppeteer-extra" ]; then
    echo "Failed to install puppeteer-extra. Exiting."
    exit 1
fi

# Read URLs from the file and download sequentially
while IFS= read -r DOWNLOAD_URL; do
    # Remove the "https://www.curseforge.com" prefix from the URL
    FOLDER_STRUCTURE="${DOWNLOAD_URL#https://www.curseforge.com/}"

    # Create the directory, including parent directories as needed
    mkdir -p "$SCRIPT_DIR/$FOLDER_STRUCTURE"

    echo "About to run Node.js script with CHROME_PATH: $CHROME_PATH"
    echo "FULL_DIR_PATH being sent to Node.js: $SCRIPT_DIR/$FOLDER_STRUCTURE"
    node "$SCRIPT_DIR/downloadFromCurseForge.js" "$DOWNLOAD_URL" "$CHROME_PATH" "$SCRIPT_DIR/$FOLDER_STRUCTURE"
done < "$FILE_PATH"
