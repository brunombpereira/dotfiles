#!/usr/bin/env bash
# Remove the symlinks created by lib/50-symlinks.sh and optionally restore
# the most recent ~/.dotfiles-backup-* directory.
#
# This does NOT uninstall apt packages, asdf, postgres, or zsh plugins —
# those are system-wide changes and removing them is outside the scope of
# a dotfiles teardown. See README "Uninstall" for the manual recipe.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly DOTFILES_DIR

# Keep this list in sync with LINKS in lib/50-symlinks.sh.
LINKS=(
    ".zshrc"
    ".zsh"
    ".gitconfig"
    ".gitignore_global"
    ".gemrc"
    ".config/nvim/init.lua"
    ".config/fastfetch"
)

usage() {
    cat <<EOF
Usage: $0 [options]

Remove dotfiles-managed symlinks from \$HOME, then optionally restore the
most recent backup directory (~/.dotfiles-backup-YYYYmmdd-HHMMSS/).

Options:
  --restore-backup   After unlinking, restore files from the newest backup dir.
  --dry-run          Print actions without performing them.
  -h, --help         Show this help and exit.
EOF
}

DRY_RUN=0
RESTORE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=1 ;;
        --restore-backup) RESTORE=1 ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "(dry run) $*"
    else
        "$@"
    fi
}

echo "Removing dotfiles symlinks from $HOME..."
for rel in "${LINKS[@]}"; do
    dst="$HOME/$rel"
    if [ ! -L "$dst" ]; then
        echo "  skip: $dst (not a symlink)"
        continue
    fi
    target="$(readlink -f "$dst" || true)"
    if [[ "$target" != "$DOTFILES_DIR/"* ]]; then
        echo "  skip: $dst (symlink points outside $DOTFILES_DIR — leaving alone)"
        continue
    fi
    run rm "$dst"
    echo "  removed: $dst"
done

if [ "$RESTORE" -eq 1 ]; then
    shopt -s nullglob
    BACKUPS=("$HOME"/.dotfiles-backup-*)
    shopt -u nullglob
    if [ "${#BACKUPS[@]}" -eq 0 ]; then
        echo "No ~/.dotfiles-backup-* directory found; nothing to restore."
        exit 0
    fi
    # Pick the most recent by timestamp suffix (sort handles YYYYmmdd-HHMMSS lexically).
    NEWEST="$(printf '%s\n' "${BACKUPS[@]}" | sort | tail -n 1)"
    echo
    echo "Restoring from $NEWEST..."
    # Use a subshell with cd so relative paths under the backup map back to $HOME.
    while IFS= read -r -d '' file; do
        rel="${file#"$NEWEST"/}"
        dst="$HOME/$rel"
        run mkdir -p "$(dirname "$dst")"
        run mv "$file" "$dst"
        echo "  restored: $dst"
    done < <(find "$NEWEST" -type f -print0)
    # Best-effort: remove now-empty backup dir.
    if [ "$DRY_RUN" -ne 1 ]; then
        find "$NEWEST" -type d -empty -delete 2>/dev/null || true
    fi
fi

echo
echo "Done."
[ "$RESTORE" -ne 1 ] && echo "Tip: pass --restore-backup to also restore the most recent backup directory."
