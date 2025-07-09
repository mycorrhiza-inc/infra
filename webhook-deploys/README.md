# Webhook Deployment Server

This project implements a FastAPI server to automate the deployment of the Kessler project from a GitHub repository.

## Features

- **Automated Deployments:** Automatically deploys the `main` branch to a nightly environment upon new commits.
- **Manual Deployments:** Provides an API endpoint to manually trigger deployments of specific commits to either `nightly` or `production` environments.
- **Real-time Output:** Streams the entire build and deployment process to the client for manual deployments.
- **Secure:** Verifies GitHub webhook signatures to ensure that requests are legitimate.

## Setup

### 1. Install Dependencies

This project uses `uv` for dependency management. To install the required packages, run:

```bash
uv sync
```

### 2. Environment Variables

For the webhook to be secure, you need to set a secret token. This token will be used to verify that the requests are coming from GitHub.

```bash
export GITHUB_WEBHOOK_SECRET="your_super_secret_token"
```

### 3. GitHub Webhook Configuration

In your `mycorrhiza-inc/kessler` repository, go to **Settings > Webhooks** and add a new webhook with the following settings:

- **Payload URL:** `http://<your_server_ip>:8000/webhook`
- **Content type:** `application/json`
- **Secret:** The same secret token you set in the `GITHUB_WEBHOOK_SECRET` environment variable.
- **Which events would you like to trigger this webhook?** Just the `push` event.

### 4. Running the Server

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

### `POST /webhook`

This endpoint is for GitHub webhooks. When a new commit is pushed to the `main` branch, it will automatically trigger a deployment to the `nightly` environment.

### `GET /`

Returns a simple message to indicate that the server is running.

**Example:**

```bash
curl http://<your_server_ip>:8000
```
