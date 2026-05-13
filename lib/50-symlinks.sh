#!/usr/bin/env bash
set -euo pipefail

readonly STEP="50-symlinks"
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
readonly BACKUP_DIR="$HOME/.dotfiles-backup-${TIMESTAMP}"

# Paths to link, relative to home/ in the repo and to $HOME in the system
LINKS=(
    ".zshrc"
    ".zsh"
    ".gitconfig"
    ".gitignore_global"
    ".config/starship.toml"
    ".config/nvim/init.lua"
)

backup_if_real_file() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        local rel="${target#$HOME/}"
        local backup_target="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$backup_target")"
        mv "$target" "$backup_target"
        echo "[$STEP] backed up $target -> $backup_target"
    fi
}

for rel in "${LINKS[@]}"; do
    src="$DOTFILES_DIR/home/$rel"
    dst="$HOME/$rel"

    if [ ! -e "$src" ]; then
        echo "[$STEP] WARN: source missing: $src (skipping)"
        continue
    fi

    mkdir -p "$(dirname "$dst")"
    backup_if_real_file "$dst"

    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        echo "[$STEP] already linked: $dst"
    else
        # Remove existing symlink (if any) then create new one
        [ -L "$dst" ] && rm "$dst"
        ln -sn "$src" "$dst"
        echo "[$STEP] linked: $dst -> $src"
    fi
done

echo "[$STEP] done"
