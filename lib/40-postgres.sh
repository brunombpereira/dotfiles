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
    echo "[$STEP] adding trust auth for $USER at top of pg_hba.conf..."
    # The trust rules MUST come before the default catch-all
    # `host all all ... scram-sha-256` line — pg_hba.conf is processed in
    # order and the first match wins. Insert immediately after the
    # `# TYPE  DATABASE` header so our rules are evaluated first.
    sudo python3 - "$PG_HBA" "$USER" <<'PYEOF'
import sys, shutil, time
path, user = sys.argv[1], sys.argv[2]
shutil.copy(path, f"{path}.bak.{int(time.time())}")
with open(path) as f:
    lines = f.readlines()
block = [
    "\n",
    "# dotfiles-trust-local -- managed by ~/.dotfiles/lib/40-postgres.sh\n",
    f"local   all             {user}                                   trust\n",
    f"host    all             {user}           127.0.0.1/32            trust\n",
    f"host    all             {user}           ::1/128                 trust\n",
    "\n",
]
out, done = [], False
for line in lines:
    out.append(line)
    if not done and line.startswith("# TYPE  DATABASE"):
        out.extend(block)
        done = True
if not done:
    # Fallback: prepend (no header found — unusual pg_hba)
    out = block + lines
with open(path, "w") as f:
    f.writelines(out)
PYEOF
    if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running --quiet 2>/dev/null; then
        sudo systemctl reload postgresql
    else
        sudo service postgresql reload
    fi
fi

echo "[$STEP] done"
