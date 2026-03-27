#!/bin/zsh
echo "=== Undoing NemoClaw (DGX Spark) ==="

# ── 1. Stop and remove gateway service ───────────────────────────
sudo systemctl stop openshell-gateway.service 2>/dev/null || true
sudo systemctl disable openshell-gateway.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/openshell-gateway.service
sudo systemctl daemon-reload
echo "✓ Gateway service removed"

# ── 2. Restore Ollama to localhost only ───────────────────────────
sudo rm -f /etc/systemd/system/ollama.service.d/override.conf
sudo rmdir /etc/systemd/system/ollama.service.d 2>/dev/null || true
sudo systemctl daemon-reload
sudo systemctl restart ollama 2>/dev/null || true
echo "✓ Ollama restored to localhost"

# ── 3. Remove openshell binary ────────────────────────────────────
rm -f ~/.local/bin/openshell
echo "✓ openshell binary removed"

# ── 4. Uninstall NemoClaw ─────────────────────────────────────────
curl -fsSL https://raw.githubusercontent.com/NVIDIA/NemoClaw/refs/heads/main/uninstall.sh | bash -s -- --yes 2>/dev/null || true
sudo npm uninstall -g nemoclaw 2>/dev/null || true
echo "✓ NemoClaw uninstall attempted"

# ── 5. Remove Docker containers and images ────────────────────────
docker rm -f $(docker ps -aq --filter "name=openshell") 2>/dev/null || true
docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E 'openshell|nemoclaw|sandbox-from|sandbox-base') 2>/dev/null || true
echo "✓ Docker artifacts removed"

# ── 6. Clean up shell config ──────────────────────────────────────
sed -i "/alias nemoclaw=/d" ~/.zshrc
echo "✓ .zshrc cleaned"

echo ""
echo "=== Done. Reboot to clear any residual sysctl state ==="
echo "    sudo reboot"
