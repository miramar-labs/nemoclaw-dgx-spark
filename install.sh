#!/bin/zsh
set -e
echo "=== NemoClaw DGX Spark Install ==="

# ── 1. Docker ─────────────────────────────────────────────────────
echo "[1/5] Ensuring Docker is running..."
sudo systemctl enable docker
sudo systemctl start docker
for i in $(seq 1 30); do
    docker info &>/dev/null && break
    echo "Waiting for Docker... ($i/30)"
    sleep 2
done
docker info &>/dev/null || { echo "ERROR: Docker failed to start"; exit 1; }

# ── 2. Ollama on 0.0.0.0 ──────────────────────────────────────────
echo "[2/5] Configuring Ollama to listen on all interfaces..."
sudo mkdir -p /etc/systemd/system/ollama.service.d
cat << 'EOF' | sudo tee /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
EOF
sudo systemctl daemon-reload
sudo systemctl restart ollama
echo "✓ Ollama configured"

# ── 3. Install openshell ───────────────────────────────────────────
echo "[3/5] Installing openshell 0.0.13..."
ARCH=$(uname -m)
wget -q "https://github.com/NVIDIA/OpenShell/releases/download/v0.0.13/openshell-${ARCH}-unknown-linux-musl.tar.gz" \
    -O /tmp/openshell.tar.gz
tar xzf /tmp/openshell.tar.gz -C /tmp
install -m 755 /tmp/openshell ~/.local/bin/openshell
echo "openshell: $(openshell --version)"

# ── 4. Boot service ───────────────────────────────────────────────
echo "[4/5] Installing boot service..."
OPENSHELL_BIN=$(which openshell)
sudo tee /etc/systemd/system/openshell-gateway.service << EOF
[Unit]
Description=OpenShell Gateway
After=docker.service
Requires=docker.service
[Service]
Type=oneshot
ExecStart=${OPENSHELL_BIN} gateway start --name nemoclaw
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable openshell-gateway.service
echo "✓ Boot service installed"

# ── 5. Install NemoClaw ───────────────────────────────────────────
echo "[5/5] Installing NemoClaw..."
echo ""
echo ">>> IMPORTANT: press ENTER for default sandbox name 'my-assistant'"
echo ">>> Choose local Ollama for inference"
echo ""
curl -fsSL https://www.nvidia.com/nemoclaw.sh | bash

echo ""
echo "=== Install complete ==="
echo "Run: nemoclaw my-assistant connect"
