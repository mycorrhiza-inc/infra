#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# pull dependencies from infra repo
git pull

# Install dependencies
uv sync

# Run the server as root
uv run main.py --host 0.0.0.0 --port 8000
