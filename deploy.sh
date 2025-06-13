#!/usr/bin/env bash
set -euo pipefail

# Usage: ./deploy.sh [--server|-s]
#   no args   → deploy to localhost
#   --server  → deploy to homelab-server

LIMIT="localhost"
TARGET_DESC="Locally (localhost)"

if [[ "${1-}" =~ ^(-s|--server)$ ]]; then
  LIMIT="homelab-server"
  TARGET_DESC="Remotely (homelab-server)"
fi

echo "→ Pulling latest changes…"
git pull origin main

echo "→ Deploying services ${TARGET_DESC} with Ansible…"
ANSIBLE_STDOUT_CALLBACK=debug \
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook \
  -i ansible/inventory/hosts.yml \
  ansible/playbook.yml \
  --limit "${LIMIT}" \
  --ask-become-pass

echo "✔ Deployment complete (${TARGET_DESC})."