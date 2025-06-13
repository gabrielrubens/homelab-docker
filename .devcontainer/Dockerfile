# .devcontainer/Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    python3-docker \
    python3-requests \
    git \
    ansible \
    openssh-client \
 && rm -rf /var/lib/apt/lists/*

# Ensure 'vscode' user can use Docker
RUN usermod -aG docker vscode || true