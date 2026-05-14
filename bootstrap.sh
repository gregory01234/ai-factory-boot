#!/bin/bash
set -euo pipefail

echo "🚀 AI FACTORY BOOT v3 START (DETERMINISTIC MODE)"

REPO_DIR="$HOME/ai-factory-boot"

# =========================
# 1. BASE SYSTEM SETUP
# =========================
echo "📦 installing base dependencies..."
apt update -y
apt install -y git curl ca-certificates ansible

# =========================
# 2. K3S INSTALL (IF MISSING)
# =========================
echo "🔍 checking k3s..."

if ! command -v kubectl >/dev/null 2>&1 || [ ! -f /etc/rancher/k3s/k3s.yaml ]; then
  echo "🚀 installing k3s..."
  curl -sfL https://get.k3s.io | sh -

  echo "⏳ waiting for k3s API..."
  sleep 10

  # wait until kubeconfig exists
  while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
    echo "⏳ waiting for kubeconfig..."
    sleep 2
  done
fi

# =========================
# 3. KUBECONFIG FIX
# =========================
echo "🔧 configuring kubeconfig..."

mkdir -p $HOME/.kube
cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config || true
chown $(id -u):$(id -g) $HOME/.kube/config || true

export KUBECONFIG=$HOME/.kube/config
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc || true

# =========================
# 4. WAIT FOR K8S READY
# =========================
echo "⏳ waiting for Kubernetes to be READY..."

until kubectl get nodes >/dev/null 2>&1; do
  echo "⏳ cluster not ready yet..."
  sleep 3
done

echo "✅ Kubernetes READY"

# =========================
# 5. CLONE SYSTEMS
# =========================
echo "📥 preparing workspace..."
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"

git clone https://github.com/gregory01234/ai-orchestrator.git "$REPO_DIR/ai-orchestrator"
git clone https://github.com/gregory01234/ai-agent-base.git "$REPO_DIR/ai-agent-base"

# =========================
# 6. WAIT FOR STABILITY
# =========================
echo "⏳ waiting cluster stabilization..."
sleep 5

kubectl get nodes
kubectl get pods -A || true

# =========================
# 7. BOOT ORCHESTRATOR
# =========================
echo "🚀 starting orchestrator..."

cd "$REPO_DIR/ai-orchestrator"
chmod +x system.sh

sudo ./system.sh bootstrap

# =========================
# 8. FINAL WAIT + VERIFY
# =========================
echo "⏳ final stabilization check..."
sleep 5

kubectl get pods -A

echo ""
echo "✅ FACTORY READY (v3)"
echo "🧠 orchestrator: active"
echo "📦 kubernetes: stable"
echo "⚙️ factory: enabled"
