#!/bin/bash
set -euo pipefail

echo "🚀 AI FACTORY BOOT v2 START"

REPO_DIR="$HOME/ai-factory-boot"

# =========================
# 1. SYSTEM DEPENDENCIES
# =========================
echo "📦 installing base dependencies..."
apt update -y
apt install -y git curl docker.io ca-certificates

# =========================
# 2. KUBECTL FIX (K3S SAFE)
# =========================
echo "🔧 checking kubectl..."

if ! command -v kubectl >/dev/null 2>&1; then
  echo "📦 kubectl not found"

  # k3s standard path fix
  if [ -f /etc/rancher/k3s/k3s.yaml ]; then
    echo "🔗 configuring k3s kubeconfig"
    mkdir -p $HOME/.kube
    cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config || true
    export KUBECONFIG=$HOME/.kube/config
    echo "export KUBECONFIG=$HOME/.kube/config" >> ~/.bashrc
  else
    echo "⚠️ k3s not detected — installing kubectl binary"
    curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  fi
fi

# =========================
# 3. CLEAN REPO STATE
# =========================
echo "🧹 preparing factory workspace..."
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"

# =========================
# 4. CLONE CORE SYSTEMS
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

sudo ./system.sh bootstrap

echo ""
echo "✅ FACTORY READY"
echo "🧠 orchestrator: running"
echo "📦 registry: inside k8s"
echo "⚙️ factory: system.sh active"
