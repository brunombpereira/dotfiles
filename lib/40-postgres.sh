#!/usr/bin/env bash
set -euo pipefail

readonly STEP="40-postgres"
readonly PG_MAJOR="16"
readonly PG_HBA="/etc/postgresql/${PG_MAJOR}/main/pg_hba.conf"

echo "[$STEP] installing postgresql-${PG_MAJOR}..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    "postgresql-${PG_MAJOR}" "postgresql-contrib-${PG_MAJOR}"

echo "[$STEP] ensuring postgres service is running..."
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running --quiet 2>/dev/null; then
    sudo systemctl enable --now postgresql
else
    sudo service postgresql start || true
fi

# Wait up to 10s for socket to be ready
for _ in $(seq 1 10); do
    sudo -u postgres psql -tAc 'SELECT 1' >/dev/null 2>&1 && break
    sleep 1
done

echo "[$STEP] ensuring role '$USER' exists with CREATEDB LOGIN..."
if ! sudo -u postgres psql -tAc \
    "SELECT 1 FROM pg_roles WHERE rolname='$USER'" | grep -q 1; then
    sudo -u postgres createuser --createdb --login "$USER"
fi

if ! sudo grep -q "# dotfiles-trust-local" "$PG_HBA"; then
    echo "[$STEP] adding trust auth for $USER on localhost in pg_hba.conf..."
    sudo tee -a "$PG_HBA" >/dev/null <<EOF

# dotfiles-trust-local — managed by ~/.dotfiles/lib/40-postgres.sh
local   all             $USER                                   trust
host    all             $USER           127.0.0.1/32            trust
host    all             $USER           ::1/128                 trust
EOF
    if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running --quiet 2>/dev/null; then
        sudo systemctl reload postgresql
    else
        sudo service postgresql reload
    fi
fi

echo "[$STEP] done"
