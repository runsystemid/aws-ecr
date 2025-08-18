# AWS ECR Login Cron Container

This project provides a containerized workflow for automatically logging into AWS ECR using the AWS CLI and Docker, scheduled via cron. It is designed for use on Amazon Linux.

## Features
- Installs AWS CLI v2 and Docker inside the container
- Uses cron to run `aws ecr login` at startup and three times a day
- Credentials and ECR address are provided via `.env` file
- Easily extendable for use with Watchtower or other automation tools

## Files
- `Dockerfile`: Builds the container with AWS CLI, Docker, and cron
- `entrypoint.sh`: Entrypoint script that logs into ECR and starts cron in foreground
- `ecr-cron`: Crontab file to schedule ECR login
- `docker-compose.yml`: Example Compose file for running the container
- `.env.example`: Example environment file for credentials

## Usage
1. Copy `.env.example` to `.env` and fill in your AWS credentials and ECR address.
2. Build and run the container:
   ```sh
   docker-compose up -d --build
   ```
3. The container will log in to ECR at startup and at 00:01, 08:01, and 16:01 UTC every day.

## Environment Variables
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `AWS_REGION`: AWS region (e.g., `us-east-1`)
- `ECR_ADDRESS`: Your ECR registry address

## Architecture
- The Dockerfile uses Amazon Linux 2 as the base image.
- The Compose file sets the platform (adjust as needed for your host).
- Cron is started in the foreground to keep the container running.

## Notes
- The Docker CLI is installed inside the container for ECR login.
- The cron daemon is started with `crond -n`.
- For ARM64 Macs, use the ARM64 base image and set `platform: linux/arm64` in Compose.
- For Watchtower integration, mount `/root/.docker/config.json` as needed.

## License
MIT
