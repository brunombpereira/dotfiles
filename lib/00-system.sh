#!/usr/bin/env bash
set -euo pipefail

readonly STEP="00-system"

echo "[$STEP] updating apt index..."
sudo apt-get update -qq

echo "[$STEP] installing base packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    less \
    libffi-dev \
    libpq-dev \
    libreadline-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    locales \
    software-properties-common \
    unzip \
    zlib1g-dev

if ! command -v gh >/dev/null 2>&1; then
    echo "[$STEP] installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg status=none
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gh
fi

echo "[$STEP] generating en_US.UTF-8 locale..."
sudo locale-gen en_US.UTF-8 >/dev/null 2>&1 || true

echo "[$STEP] done"
