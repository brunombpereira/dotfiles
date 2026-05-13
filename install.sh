#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly LIB_DIR="$SCRIPT_DIR/lib"
readonly EXPECTED_PATH="$HOME/.dotfiles"

if [ "$SCRIPT_DIR" != "$EXPECTED_PATH" ] && [ "${1:-}" != "--force" ]; then
    cat >&2 <<EOF
ERROR: this repo should be cloned to $EXPECTED_PATH
       (you cloned it to $SCRIPT_DIR)

Either move it:
  mv "$SCRIPT_DIR" "$EXPECTED_PATH"

Or re-run with --force to override (symlinks will still target $SCRIPT_DIR):
  $0 --force
EOF
    exit 1
fi

if [ ! -d "$LIB_DIR" ]; then
    echo "ERROR: lib/ directory missing at $LIB_DIR" >&2
    exit 1
fi

echo "Starting dotfiles bootstrap from $SCRIPT_DIR"
echo

shopt -s nullglob
SCRIPTS=("$LIB_DIR"/[0-9][0-9]-*.sh)
shopt -u nullglob

if [ "${#SCRIPTS[@]}" -eq 0 ]; then
    echo "ERROR: no lib/NN-*.sh scripts found" >&2
    exit 1
fi

for script in "${SCRIPTS[@]}"; do
    echo "─── $(basename "$script") ───────────────────────────────"
    bash "$script"
    echo
done
