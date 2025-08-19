# AWS ECR Login Cron Container

Containerized workflow to log into AWS ECR using AWS CLI and Docker, scheduled by cron. Built on Amazon Linux 2.

## Features
- Installs AWS CLI v2 and Docker CLI inside the container
- Runs an initial ECR login at startup, then repeats on a cron schedule
- Credentials and ECR address provided via `.env`
- Writes logs to a bind-mounted host directory

## Files
- `Dockerfile` — Builds the image with AWS CLI, Docker CLI, and cron
- `entrypoint.sh` — Does an initial login, exports env for cron, starts cron in foreground
- `ecr-cron` — Crontab entries that trigger the login script
- `ecr-login.sh` — Login helper invoked by cron and at startup
- `docker-compose.yml` — Example Compose service definition
- `.env.example` — Example environment file to copy to `.env`
- `log/ecr-cron.log` — Login script log (bind-mounted from `./log`)

## Usage
1. Copy `.env.example` to `.env` and fill in your AWS credentials and ECR address.
2. Build and run the container:
   ```sh
   docker-compose up -d --build
   ```
3. Check logs:
   ```sh
   tail -f ./log/ecr-cron.log
   ```

## Default schedule
- The container logs into ECR once at startup and, by default, every minute via cron (see `ecr-cron`).
- To change the schedule (e.g., run at 00:01, 08:01, and 16:01 UTC), edit `ecr-cron` accordingly. Example line:
  ```cron
  1 0,8,16 * * * root . /etc/environment; /usr/local/bin/ecr-login.sh
  ```

## Environment variables
- `AWS_ACCESS_KEY_ID` — Your AWS access key
- `AWS_SECRET_ACCESS_KEY` — Your AWS secret key
- `AWS_REGION` — AWS region (e.g., `us-east-1`)
- `ECR_ADDRESS` — Your ECR registry address (e.g., `123456789012.dkr.ecr.us-east-1.amazonaws.com`)

Notes on env for cron:
- `entrypoint.sh` writes selected environment variables (matching `AWS_` and `ECR_`) and the PATH to `/etc/environment` so cron jobs can access them.

## Architecture and platform
- Base image: Amazon Linux 2.
- Cron runs in the foreground (`crond -n`) to keep the container alive.
- The image installs the Docker CLI (not the Docker daemon). The ECR auth is stored at `/root/.docker/config.json` inside this container.
- `docker-compose.yml` sets `platform: linux/amd64`. The Dockerfile downloads the AMD64 AWS CLI v2 artifact.

ARM64 (Apple Silicon) options:
- Use emulation with the default image (works out of the box but uses `linux/amd64`).
- Or build a native ARM64 image by updating the AWS CLI download in `Dockerfile` to `awscli-exe-linux-aarch64.zip` and switching Compose to `platform: linux/arm64`.

## Sharing auth with other containers (optional)
If another container (e.g., Watchtower) needs to reuse the ECR auth, mount `/root/.docker` as a named volume in both services so they share `config.json`.

## License
MIT
