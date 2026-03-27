#!/bin/zsh
set -e
echo "=== Restarting NemoClaw ==="

# ── 1. Ensure Docker is running ───────────────────────────────────
sudo systemctl start docker
for i in $(seq 1 30); do
    docker info &>/dev/null && break
    echo "Waiting for Docker... ($i/30)"
    sleep 2
done
docker info &>/dev/null || { echo "ERROR: Docker failed to start"; exit 1; }

# ── 2. Destroy and restart gateway ────────────────────────────────
openshell gateway destroy --name nemoclaw 2>/dev/null || true
openshell gateway start --name nemoclaw

# ── 3. Connect or prompt onboard ──────────────────────────────────
# If sandbox exists, connect. Otherwise onboard, then connect.
if nemoclaw list 2>/dev/null | grep -qw 'my-assistant'; then
    nemoclaw my-assistant connect
else
    echo ""
    echo "No sandbox found for my-assistant."
    echo "Starting onboard..."
    nemoclaw onboard

    # Clear stale forward again in case onboard partially set one up
    openshell forward stop 18789 my-assistant 2>/dev/null || true

    if nemoclaw list 2>/dev/null | grep -qw 'my-assistant'; then
        nemoclaw my-assistant connect
    else
        echo "Sandbox still not available after onboard."
        echo "Run: nemoclaw list"
        exit 1
    fi
fi