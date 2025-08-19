#!/bin/sh
set -e

# Ensure logs directory exists
mkdir -p /app/logs

# Run ECR login at startup (do not abort container on failure)
/usr/local/bin/ecr-login.sh || true

# Make environment visible to cron jobs via /etc/environment (cron does not source profile.d)
{
	# Preserve PATH first
	printf 'PATH="%s"\n' "$PATH"
	# Add AWS_ and ECR_ variables without leading spaces
	printenv | awk -F= '/^(AWS_|ECR_)/ {key=$1; val=substr($0, index($0, "=")+1); gsub(/"/,"\\\"", val); printf "%s=\"%s\"\n", key, val }'
} > /etc/environment

# Start cron in foreground
crond -n
