#!/usr/bin/env bash
set -euo pipefail

cd /home/gabriel/homelab-docker
git pull origin main

for svc in dashy pihole netdata glances homepage; do
  cd "$svc"
  docker-compose pull
  docker-compose up -d
done