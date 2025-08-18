#!/bin/sh
set -e

# Run ECR login at startup
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_ADDRESS"

# Start cron in foreground
crond -n
