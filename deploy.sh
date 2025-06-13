#!/usr/bin/env bash
set -euo pipefail

# Where your repo lives on the server
#REPO_DIR="/home/gabriel/homelab-docker"

#cd "$REPO_DIR"

echo "Pulling latest changes…"
git pull origin main

echo "Running Ansible playbook to deploy all services…"
# If you run this on the homelab server itself, limit to 'localhost'; 
# if you run it remotely, limit to 'homelab-server'
ANSIBLE_STDOUT_CALLBACK=debug \
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook \
  -i ansible/inventory/hosts.yml \
  ansible/playbook.yml \
  --limit localhost \
  --ask-become-pass

echo "Done."