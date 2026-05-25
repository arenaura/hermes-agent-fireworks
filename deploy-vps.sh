#!/bin/bash
set -e

# ── Hermes Agent — VPS Deployment Script ────────────────────────────────────
# Run this on your Ubuntu/Debian VPS after SSH-ing in.
# Usage: bash deploy-vps.sh

echo "=== Hermes Agent VPS Deployment ==="
echo ""

# ── 1. System packages ──────────────────────────────────────────────────────
echo "[1/5] Updating system & installing prerequisites..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y git curl ca-certificates

# ── 2. Docker ───────────────────────────────────────────────────────────────
if command -v docker &>/dev/null; then
    echo "[2/5] Docker already installed — skipping."
else
    echo "[2/5] Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
    echo "  → Docker installed. You may need to log out and back in"
    echo "    for group membership to take effect. If the build fails"
    echo "    with 'permission denied', run: newgrp docker"
fi

# ── 3. Clone repo ───────────────────────────────────────────────────────────
DEPLOY_DIR="$HOME/hermes-agent"
if [ -d "$DEPLOY_DIR" ]; then
    echo "[3/5] Directory $DEPLOY_DIR exists — pulling latest..."
    cd "$DEPLOY_DIR" && git pull
else
    echo "[3/5] Cloning repository..."
    git clone https://github.com/arenaura/hermes-agent-fireworks.git "$DEPLOY_DIR"
    cd "$DEPLOY_DIR"
fi

# ── 4. Environment file ────────────────────────────────────────────────────
if [ ! -f .env ]; then
    echo "[4/5] Creating .env from .env.example..."
    cp .env.example .env
    echo ""
    echo "  ⚠  IMPORTANT: Edit .env and add your API keys before starting!"
    echo "     Required: FIREWORKS_API_KEY and LLM_MODEL (or another provider)"
    echo "     Run: nano $DEPLOY_DIR/.env"
    echo ""
    echo "     After editing .env, run the remaining steps:"
    echo "     cd $DEPLOY_DIR && docker compose up -d --build"
    echo ""
    exit 0
else
    echo "[4/5] .env already exists — keeping it."
fi

# ── 5. Build & start ────────────────────────────────────────────────────────
echo "[5/5] Building & starting Hermes Agent..."
docker compose up -d --build

echo ""
echo "=== Deployment complete! ==="
echo ""
echo "  Agent URL:  http://$(hostname -I | awk '{print $1}'):8080"
echo "  Setup page: http://$(hostname -I | awk '{print $1}'):8080/setup"
echo ""
echo "  Useful commands:"
echo "    docker compose logs -f          # view logs"
echo "    docker compose restart          # restart agent"
echo "    docker compose down             # stop agent"
echo "    docker compose up -d --build    # rebuild after code changes"
