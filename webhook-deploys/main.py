import asyncio
import os
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
from fastapi.responses import StreamingResponse
import subprocess
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from git import Repo, GitCommandError

# --- Configuration ---
KESSLER_REPO_PATH = "/mycorrhiza/kessler"
DOCKER_USERNAME = "fractalhuman1"
REPO_URL = "https://github.com/mycorrhiza-inc/kessler"

app = FastAPI()
scheduler = AsyncIOScheduler()


# --- Models ---
class DeployRequest(BaseModel):
    commit: str
    environment: str  # "nightly" or "production"


# --- Git Operations ---
def get_repo() -> Repo:
    """
    Initializes and returns a Git Repo object. Clones if it doesn't exist.
    """
    if not os.path.exists(KESSLER_REPO_PATH):
        print(f"Cloning repository into {KESSLER_REPO_PATH}...")
        Repo.clone_from(REPO_URL, KESSLER_REPO_PATH, recurse_submodules=True)
        print("Repository cloned.")
    return Repo(KESSLER_REPO_PATH)


def get_latest_commit_hash(repo: Repo, branch: str = "main") -> str:
    """
    Fetches the latest commit hash from the remote repository.
    """
    try:
        repo.remotes.origin.fetch()
        latest_commit = repo.remotes.origin.refs[branch].commit.hexsha
        return latest_commit
    except GitCommandError as e:
        print(f"Error fetching latest commit: {e}")
        return ""


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
    cd {KESSLER_REPO_PATH}

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
        script, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )

    # Stream stdout
    # while True:
    #     line = await process.stdout.readline()
    #     if not line:
    #         break
    #     yield line

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
        print(output.strip())
    print(f"Finished background deployment for {commit} to {environment}")


# --- Polling Logic ---
async def poll_and_deploy():
    """
    Polls the git repository for new commits and triggers a nightly deployment if found.
    """
    print("Polling for new commits...")
    repo = get_repo()
    latest_commit = get_latest_commit_hash(repo)

    if latest_commit:
        # A simple way to track the last deployed commit.
        # For a more robust solution, consider a small database or file.
        last_deployed_commit_file = "/tmp/last_deployed_commit.txt"
        last_deployed_commit = ""
        if os.path.exists(last_deployed_commit_file):
            with open(last_deployed_commit_file, "r") as f:
                last_deployed_commit = f.read().strip()

        if latest_commit != last_deployed_commit:
            print(f"New commit found: {latest_commit}. Triggering nightly deployment.")
            await run_deployment_task(latest_commit, "nightly")
            with open(last_deployed_commit_file, "w") as f:
                f.write(latest_commit)
        else:
            print("No new commits found.")


# --- API Endpoints ---
@app.post("/deploy")
async def deploy_commit(request: DeployRequest):
    """
    Manually trigger a deployment for a specific commit.
    Streams the deployment output back to the client.
    """
    if request.environment not in ["nightly", "production"]:
        raise HTTPException(
            status_code=400,
            detail="Invalid environment. Must be 'nightly' or 'production'.",
        )

    return StreamingResponse(
        stream_deployment_process(request.commit, request.environment),
        media_type="text/plain",
    )


@app.get("/")
def read_root():
    return {"message": "Deployment server is running."}


# --- Lifecycle Events ---
@app.on_event("startup")
async def startup_event():
    """
    On startup, add the polling job to the scheduler.
    """
    scheduler.add_job(poll_and_deploy, "interval", hours=2)
    scheduler.start()
    # Run the job once on startup
    await poll_and_deploy()


@app.on_event("shutdown")
async def shutdown_event():
    """
    On shutdown, stop the scheduler.
    """
    scheduler.shutdown()


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
