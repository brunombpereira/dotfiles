#!/usr/bin/env bash
set -euo pipefail

readonly STEP="20-cli-tools"

echo "[$STEP] installing apt CLI tools..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    bat \
    direnv \
    eza \
    fzf \
    httpie \
    ripgrep

# Ubuntu ships bat as 'batcat' to avoid conflict with another package — alias as 'bat'
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if ! command -v lazygit >/dev/null 2>&1; then
    echo "[$STEP] installing lazygit from GitHub releases..."
    LAZYGIT_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | jq -r .tag_name | sed 's/^v//')
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
        -o /tmp/lazygit.tar.gz
    tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit.tar.gz /tmp/lazygit
fi

# fastfetch — not in Ubuntu 24.04 repos, install .deb from GitHub releases
if ! command -v fastfetch >/dev/null 2>&1; then
    echo "[$STEP] installing fastfetch from GitHub releases..."
    FASTFETCH_VERSION=$(curl -fsSL https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
        | jq -r .tag_name)
    ARCH=$(dpkg --print-architecture)
    curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/download/${FASTFETCH_VERSION}/fastfetch-linux-${ARCH}.deb" \
        -o /tmp/fastfetch.deb
    sudo dpkg -i /tmp/fastfetch.deb
    rm /tmp/fastfetch.deb
fi

echo "[$STEP] done"
