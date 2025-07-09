#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# Install dependencies
uv sync

# Run the server as root
uv run --host 0.0.0.0 --port 8000
