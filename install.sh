#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly LIB_DIR="$SCRIPT_DIR/lib"
readonly EXPECTED_PATH="$HOME/.dotfiles"
readonly LOG_FILE="$SCRIPT_DIR/install.log"

usage() {
    cat <<EOF
Usage: $0 [options]

Run the dotfiles bootstrap. Each lib/NN-*.sh is idempotent; re-running is safe.

Options:
  --dry-run         Print the steps that would run, without executing them.
  --only NN[,NN]    Only run lib/ steps whose numeric prefix is in the list
                    (e.g. --only 10,20 runs 10-shell.sh and 20-cli-tools.sh).
  --skip NN[,NN]    Skip lib/ steps whose numeric prefix is in the list.
  --force           Run even if the repo isn't cloned to $EXPECTED_PATH.
  --no-log          Don't tee output to $LOG_FILE.
  -h, --help        Show this help and exit.
EOF
}

DRY_RUN=0
FORCE=0
NO_LOG=0
ONLY=""
SKIP=""

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=1 ;;
        --force) FORCE=1 ;;
        --no-log) NO_LOG=1 ;;
        --only)
            [ $# -ge 2 ] || {
                echo "ERROR: --only requires an argument" >&2
                exit 2
            }
            ONLY="$2"
            shift
            ;;
        --only=*) ONLY="${1#*=}" ;;
        --skip)
            [ $# -ge 2 ] || {
                echo "ERROR: --skip requires an argument" >&2
                exit 2
            }
            SKIP="$2"
            shift
            ;;
        --skip=*) SKIP="${1#*=}" ;;
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

if [ "$SCRIPT_DIR" != "$EXPECTED_PATH" ] && [ "$FORCE" -ne 1 ]; then
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

# Tee all output to $LOG_FILE for post-mortem debugging.
# Skipped on dry-run (nothing destructive happens) and on --no-log.
if [ "$NO_LOG" -ne 1 ] && [ "$DRY_RUN" -ne 1 ]; then
    exec > >(tee "$LOG_FILE") 2>&1
    echo "Logging to $LOG_FILE"
fi

echo "Starting dotfiles bootstrap from $SCRIPT_DIR"
[ "$DRY_RUN" -eq 1 ] && echo "(dry run — no commands will be executed)"
echo

shopt -s nullglob
# Build SCRIPTS via a loop (shfmt mis-parses [0-9] globs inside array literals)
SCRIPTS=()
for f in "$LIB_DIR"/[0-9][0-9]-*.sh; do
    SCRIPTS+=("$f")
done
shopt -u nullglob

if [ "${#SCRIPTS[@]}" -eq 0 ]; then
    echo "ERROR: no lib/NN-*.sh scripts found" >&2
    exit 1
fi

# Returns 0 if "$1" appears as a comma-separated entry in "$2".
in_csv() {
    local needle="$1" haystack="$2"
    case ",$haystack," in
        *",$needle,"*) return 0 ;;
        *) return 1 ;;
    esac
}

RAN=0
for script in "${SCRIPTS[@]}"; do
    base="$(basename "$script")"
    prefix="${base%%-*}"

    if [ -n "$ONLY" ] && ! in_csv "$prefix" "$ONLY"; then
        echo "─── $base ─── (skipped: not in --only)"
        echo
        continue
    fi
    if [ -n "$SKIP" ] && in_csv "$prefix" "$SKIP"; then
        echo "─── $base ─── (skipped: in --skip)"
        echo
        continue
    fi

    echo "─── $base ───────────────────────────────"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "(dry run) would execute: bash $script"
    else
        bash "$script"
    fi
    echo
    RAN=$((RAN + 1))
done

if [ "$RAN" -eq 0 ]; then
    echo "WARN: no steps matched the given --only/--skip filters" >&2
fi
