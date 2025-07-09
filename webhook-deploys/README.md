# Polling Deployment Server

This project implements a FastAPI server to automate the deployment of the Kessler project from a GitHub repository.

## Features

- **Automated Deployments:** Automatically deploys the `main` branch to a nightly environment every two hours if new commits are detected.
- **Manual Deployments:** Provides an API endpoint to manually trigger deployments of specific commits to either `nightly` or `production` environments.
- **Real-time Output:** Streams the entire build and deployment process to the client for manual deployments.

## Setup

### 1. Install Dependencies

This project uses `uv` for dependency management. To install the required packages, run:

```bash
uv sync
```

### 2. Running the Server

The server needs to be run as root to have the necessary permissions for `docker` and `git` commands.

```bash
sudo uv run --host 0.0.0.0 --port 8000
```

## API Endpoints

### `POST /deploy`

Manually trigger a deployment. The request body should be a JSON object with the following fields:

- `commit`: The commit hash to deploy.
- `environment`: The target environment (`nightly` or `production`).

**Example:**

```bash
curl -X POST http://<your_server_ip>:8000/deploy \
-H "Content-Type: application/json" \
-d '{"commit": "your_commit_hash", "environment": "production"}'
```

### `GET /`

Returns a simple message to indicate that the server is running.

**Example:**

```bash
curl http://<your_server_ip>:8000
```