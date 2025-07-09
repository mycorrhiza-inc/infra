#!/bin/bash
set -e

# Install dependencies
uv sync

# Run the server as root
sudo uv run --host 0.0.0.0 --port 8000
