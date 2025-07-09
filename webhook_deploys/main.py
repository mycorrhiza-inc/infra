import asyncio
import hashlib
import hmac
import os
from fastapi import FastAPI, Request, HTTPException, Header, BackgroundTasks
from pydantic import BaseModel
from fastapi.responses import StreamingResponse
import subprocess

# --- Configuration ---
# It's recommended to set this as an environment variable for security
GITHUB_WEBHOOK_SECRET = os.environ.get("GITHUB_WEBHOOK_SECRET")
KESSLER_REPO_PATH = "/mycorrhiza/kessler"
DOCKER_USERNAME = "fractalhuman1"

app = FastAPI()

# --- Models ---
class DeployRequest(BaseModel):
    commit: str
    environment: str  # "nightly" or "production"

# --- Security ---
async def verify_github_signature(request: Request):
    """
    Verify that the webhook request is from GitHub.
    This is disabled if GITHUB_WEBHOOK_SECRET is not set.
    """
    if not GITHUB_WEBHOOK_SECRET:
        print("Warning: GITHUB_WEBHOOK_SECRET is not set. Skipping signature verification.")
        return

    signature_header = request.headers.get("X-Hub-Signature-256")
    if not signature_header:
        raise HTTPException(status_code=400, detail="X-Hub-Signature-256 header is missing!")

    body = await request.body()
    expected_signature = hmac.new(GITHUB_WEBHOOK_SECRET.encode(), body, hashlib.sha256).hexdigest()

    if not hmac.compare_digest(f"sha256={expected_signature}", signature_header):
        raise HTTPException(status_code=400, detail="Invalid GitHub signature.")

# --- Deployment Logic ---
async def stream_deployment_process(commit: str, environment: str):
    """
    A generator function that yields the output of the deployment process in real-time.
    """
    deploy_host = "nightly.kessler.xyz" if environment == "nightly" else "kessler.xyz"
    deploy_flag = environment

    script = f"""
    set -e
    echo "--- Starting deployment for commit {commit} to {environment} ---"
    sudo mkdir -p {KESSLER_REPO_PATH}
    sudo chmod 777 -R {KESSLER_REPO_PATH}
    cd {KESSLER_REPO_PATH}

    if [ ! -d ".git" ]; then
        echo "--- Cloning repository ---"
        sudo git clone https://github.com/mycorrhiza-inc/kessler . --recurse-submodules
        sudo git config --global --add safe.directory {KESSLER_REPO_PATH}
    fi

    echo "--- Fetching latest changes and checking out commit ---"
    sudo git clean -fd
    sudo git fetch --all
    sudo git reset --hard HEAD
    sudo git clean -fd
    sudo git checkout {commit} --recurse-submodules
    
    current_hash=$(git rev-parse HEAD)
    echo "--- Successfully checked out commit: $current_hash ---"

    echo "--- Building Docker images ---"
    sudo docker build -t "{DOCKER_USERNAME}/kessler-frontend:${{current_hash}}" --platform linux/amd64 --file ./frontend/prod.Dockerfile ./frontend/
    sudo docker build -t "{DOCKER_USERNAME}/kessler-backend-server:${{current_hash}}" --platform linux/amd64 --file ./backend/prod.server.Dockerfile ./backend
    sudo docker build -t "{DOCKER_USERNAME}/kessler-backend-ingest:${{current_hash}}" --platform linux/amd64 --file ./backend/prod.ingest.Dockerfile ./backend
    sudo docker build -t "{DOCKER_USERNAME}/kessler-fugudb:${{current_hash}}" --platform linux/amd64 --file ./fugu/Dockerfile ./fugu

    echo "--- Pushing images to Docker Hub ---"
    sudo docker push "{DOCKER_USERNAME}/kessler-frontend:${{current_hash}}"
    sudo docker push "{DOCKER_USERNAME}/kessler-backend-server:${{current_hash}}"
    sudo docker push "{DOCKER_USERNAME}/kessler-backend-ingest:${{current_hash}}"
    sudo docker push "{DOCKER_USERNAME}/kessler-fugudb:${{current_hash}}"

    echo "--- Triggering deployment on {deploy_host} ---"
    ssh "root@{deploy_host}" "cd /mycorrhiza/kessler && git reset --hard HEAD && git clean -fd && git switch main && git pull && python3 execute_production_deploy.py --{deploy_flag} --version ${{current_hash}}"
    
    echo "--- Deployment to {environment} finished successfully ---"
    """

    process = await asyncio.create_subprocess_shell(
        script,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )

    # Stream stdout
    while True:
        line = await process.stdout.readline()
        if not line:
            break
        yield line

    # Wait for the process to finish and capture any errors
    stdout, stderr = await process.communicate()
    
    if process.returncode != 0:
        error_message = stderr.decode() if stderr else "An unknown error occurred."
        yield f"--- ERROR ---\n{error_message}"
        yield f"--- PROCESS FAILED WITH EXIT CODE {process.returncode} ---"

async def run_deployment_task(commit: str, environment: str):
    """
    A wrapper to run the deployment process and handle logging.
    """
    print(f"Starting background deployment for {commit} to {environment}")
    async for output in stream_deployment_process(commit, environment):
        print(output.decode().strip())
    print(f"Finished background deployment for {commit} to {environment}")


# --- API Endpoints ---
@app.post("/deploy")
async def deploy_commit(request: DeployRequest):
    """
    Manually trigger a deployment for a specific commit.
    Streams the deployment output back to the client.
    """
    if request.environment not in ["nightly", "production"]:
        raise HTTPException(status_code=400, detail="Invalid environment. Must be 'nightly' or 'production'.")
    
    return StreamingResponse(stream_deployment_process(request.commit, request.environment), media_type="text/plain")

@app.post("/webhook")
async def github_webhook(request: Request, background_tasks: BackgroundTasks):
    """
    Handles webhooks from GitHub. Triggers a nightly deployment on push to main.
    """
    await verify_github_signature(request)
    
    payload = await request.json()

    if payload.get("ref") == "refs/heads/main":
        commit_hash = payload.get("after")
        if commit_hash:
            print(f"New commit on main: {commit_hash}. Triggering nightly deployment.")
            background_tasks.add_task(run_deployment_task, commit_hash, "nightly")
            return {"message": "Nightly deployment triggered in the background."}

    return {"message": "Event received, but no action taken."}

@app.get("/")
def read_root():
    return {"message": "Deployment server is running."}

if __name__ == "__main__":
    import uvicorn
    # The server needs to run as root to execute docker and git with sudo
    # and to bind to a privileged port if necessary.
    # Running on 0.0.0.0 makes it accessible from the network.
    uvicorn.run(app, host="0.0.0.0", port=8000)