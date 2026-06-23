#!usr/bin/env bash

set -euo pipefail

echo "--------------------------------------"
echo "BALpipe - Initial Setup"
echo "--------------------------------------"

# Create project directories

mkdir -p \
    data/raw \
    databases \
    resources \
    visual

echo "Project basic structure initialized."

# Create user config from template

if [ ! -f config/config.yaml ]; then
    cp config/config.example.yaml config/config.yaml
    echo "Created config/config.yaml from template."
fi

echo "Project initialized."


