#!/bin/sh
set -euo pipefail

# --- helpers ---
log() { printf '[%s] %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*" >> /app/logs/ecr-cron.log; }
die() { log "ERROR: $*"; exit 1; }
require_env() { eval "_v=\${$1:-}"; [ -n "$_v" ] || die "Missing $1"; }
require_cmd() { [ -x "$1" ] || die "Command not found: $1"; }

# --- config ---
AWS=/usr/local/bin/aws
DOCKER=/usr/bin/docker

require_env AWS_REGION
require_env ECR_ADDRESS
require_cmd "$AWS"
require_cmd "$DOCKER"

login_ecr() {
  "$AWS" ecr get-login-password --region "$AWS_REGION" \
    | "$DOCKER" login --username AWS --password-stdin "$ECR_ADDRESS"
}

# --- run ---
if login_ecr; then
  log "ECR login SUCCESS for $ECR_ADDRESS"
else
  status=$?
  log "ECR login FAILED for $ECR_ADDRESS (exit=$status)"
  exit $status
fi
