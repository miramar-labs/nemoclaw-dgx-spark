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
if nemoclaw my-assistant status &>/dev/null; then
    nemoclaw my-assistant connect
else
    echo ""
    echo "No sandbox found. Run: nemoclaw onboard"
    echo "After onboard completes run: ~/nemoclaw-dgx-restart.sh"
fi
