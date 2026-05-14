#!/bin/bash
set -euo pipefail

echo "🚀 AI FACTORY BOOT v2 START"

REPO_DIR="$HOME/ai-factory-boot"

# =========================
# 1. SYSTEM DEPENDENCIES
# =========================
echo "📦 installing base dependencies..."
sudo apt update -y
sudo apt install -y git curl docker.io ca-certificates

# =========================
# 2. KUBECTL + K3S FIX (HARDENED)
# =========================
echo "🔧 configuring kubernetes access..."

K3S_CONFIG="/etc/rancher/k3s/k3s.yaml"

if [ -f "$K3S_CONFIG" ]; then
    echo "📦 k3s detected — fixing kubeconfig"

    mkdir -p "$HOME/.kube"
    sudo cp "$K3S_CONFIG" "$HOME/.kube/config"
    sudo chown $(id -u):$(id -g) "$HOME/.kube/config"
    chmod 600 "$HOME/.kube/config"

    export KUBECONFIG="$HOME/.kube/config"

    grep -q "KUBECONFIG" "$HOME/.bashrc" || \
      echo 'export KUBECONFIG=$HOME/.kube/config' >> "$HOME/.bashrc"

else
    echo "⚠️ k3s not found — installing kubectl only"
    curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# =========================
# 3. CLEAN WORKSPACE
# =========================
echo "🧹 preparing factory workspace..."
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"

# =========================
# 4. CLONE SYSTEMS
# =========================
echo "📥 cloning orchestrator..."
git clone https://github.com/gregory01234/ai-orchestrator.git "$REPO_DIR/ai-orchestrator"

echo "📥 cloning agent base..."
git clone https://github.com/gregory01234/ai-agent-base.git "$REPO_DIR/ai-agent-base"

# =========================
# 5. BOOT ORCHESTRATOR
# =========================
echo "🚀 starting orchestrator..."

cd "$REPO_DIR/ai-orchestrator"
chmod +x system.sh

sudo -E ./system.sh bootstrap

echo ""
echo "✅ FACTORY READY"
echo "🧠 orchestrator: running"
echo "📦 registry: inside k8s"
echo "⚙️ factory: system.sh active"
