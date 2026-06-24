#!/bin/bash
# =============================================================================
# Miniconda + RL Environment Setup
# Usage: bash scripts/setup_miniconda.sh
# =============================================================================
set -eu

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "${GREEN}[OK]${NC} $*"; }

MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

echo "========================================="
echo " Miniconda + RL Environments"
echo "========================================="

# ---- Step 1: Install Miniconda ----
if ! command -v conda &>/dev/null; then
    echo "Installing Miniconda..."
    wget -q "$MINICONDA_URL" -O /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
    rm /tmp/miniconda.sh
    eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
    conda init bash
    ok "Miniconda installed"
else
    eval "$("$(which conda)" shell.bash hook)"
    ok "Miniconda already installed"
fi

# ---- Step 2: Configure ----
conda config --set auto_activate_base false 2>/dev/null || true
conda config --add channels conda-forge 2>/dev/null || true
conda config --set channel_priority flexible 2>/dev/null || true
conda config --set solver libmamba 2>/dev/null || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true
ok "Conda configured"

# ---- Step 3: Create envs ----
for env in "env_isaaclab:3.10:Isaac Lab RL training" "env_ros:3.12:ROS2 device control"; do
    name="${env%%:*}"
    rest="${env#*:}"
    pyver="${rest%%:*}"
    desc="${rest##*:}"
    if conda env list | grep -q "$name"; then
        ok "$name already exists"
    else
        echo "Creating $name (Python $pyver) — $desc..."
        conda create -y -n "$name" "python=$pyver"
        ok "$name created"
    fi
done

echo ""; conda env list
echo "========================================="
echo " Conda environments ready:"
echo "   conda activate env_isaaclab  # RL training"
echo "   conda activate env_ros       # ROS2"
echo "========================================="
