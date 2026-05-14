#!/bin/bash
set -e

echo "🚀 AI FACTORY BOOT START"

REPO_DIR="$HOME/ai-factory-boot"

# 1. system update
apt update -y
apt install -y git curl docker.io

# 2. kubectl (jeśli brak k3s)
if ! command -v kubectl &> /dev/null; then
  echo "📦 kubectl missing (assuming k3s already installed)"
fi

# 3. clone orchestrator
rm -rf "$REPO_DIR"
git clone https://github.com/gregory01234/ai-orchestrator.git "$REPO_DIR/ai-orchestrator"

# 4. clone base agent
git clone https://github.com/gregory01234/ai-agent-base.git "$REPO_DIR/ai-agent-base"

# 5. start system
cd "$REPO_DIR/ai-orchestrator"
chmod +x system.sh

echo "🚀 BOOTSTRAPPING ORCHESTRATOR"
sudo ./system.sh bootstrap

echo "✅ FACTORY READY"
echo "👉 system reachable via kubectl + registry + factory"
