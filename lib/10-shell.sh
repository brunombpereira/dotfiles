#!/usr/bin/env bash
set -euo pipefail

readonly STEP="10-shell"
readonly ZSH_PLUGIN_DIR="$HOME/.local/share/zsh-plugins"

echo "[$STEP] installing zsh..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zsh

if ! command -v starship >/dev/null 2>&1; then
    echo "[$STEP] installing starship..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes >/dev/null
fi

echo "[$STEP] cloning zsh plugins to $ZSH_PLUGIN_DIR..."
mkdir -p "$ZSH_PLUGIN_DIR"
if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone --quiet --depth 1 \
        https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone --quiet --depth 1 \
        https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
fi

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
TARGET_SHELL="$(command -v zsh)"
if [ "$CURRENT_SHELL" != "$TARGET_SHELL" ]; then
    echo "[$STEP] setting default shell to zsh..."
    sudo chsh -s "$TARGET_SHELL" "$USER"
fi

echo "[$STEP] done (open a new shell to use zsh)"
