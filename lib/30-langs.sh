#!/usr/bin/env bash
set -euo pipefail

readonly STEP="30-langs"
# Note: ASDF_DIR cannot be readonly because asdf.sh itself sets it.
ASDF_DIR="$HOME/.asdf"
readonly ASDF_VERSION="v0.14.1"
readonly RUBY_VERSION="3.3.6"
readonly NODE_MAJOR="22"

if [ ! -d "$ASDF_DIR" ]; then
    echo "[$STEP] installing asdf $ASDF_VERSION..."
    git clone --quiet --branch "$ASDF_VERSION" \
        https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
fi

# Source asdf for this script
# shellcheck disable=SC1091
. "$ASDF_DIR/asdf.sh"

echo "[$STEP] adding asdf plugins (ruby, nodejs)..."
asdf plugin add ruby     https://github.com/asdf-vm/asdf-ruby.git    2>/dev/null || true
asdf plugin add nodejs   https://github.com/asdf-vm/asdf-nodejs.git  2>/dev/null || true

echo "[$STEP] installing Ruby $RUBY_VERSION (this takes 3-5 min on first run)..."
asdf install ruby "$RUBY_VERSION"
asdf global ruby "$RUBY_VERSION"

NODE_LATEST=$(asdf latest nodejs "$NODE_MAJOR")
echo "[$STEP] installing Node $NODE_LATEST..."
# Skip GPG signature checks on first install — the plugin's keyring import is
# brittle on fresh systems. Signatures can be re-enabled later if needed.
export NODEJS_CHECK_SIGNATURES=no
asdf install nodejs "$NODE_LATEST"
asdf global nodejs "$NODE_LATEST"

echo "[$STEP] installing bundler gem..."
gem install bundler --silent --no-document

echo "[$STEP] done"
