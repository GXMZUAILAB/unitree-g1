#!/bin/bash
# =============================================================================
# G1 RL Training — System Setup Script (one-click)
# Installs: docker, nvidia-ctk, ros2-lyrical, system build tools
# Usage: bash scripts/setup_system.sh
# ⚠️ Requires sudo
# =============================================================================
set -eu

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
note() { echo -e "${YELLOW}[..]${NC} $*"; }

echo "========================================="
echo " G1 RL — System Environment Setup"
echo " $(date)"
echo "========================================="

# ---- Phase 1: System build tools ----
echo ""; echo "=== Step 1/4: System Build Tools ==="
sudo apt update -qq
sudo apt install -y git build-essential cmake gcc g++ python3-pip python3-dev python3-venv wget curl
ok "git $(git --version | cut -d' ' -f3)"
ok "cmake $(cmake --version | head -1 | cut -d' ' -f3)"
ok "gcc $(gcc --version | head -1 | cut -d' ' -f4)"

# ---- Phase 2: Docker + NVIDIA Container Toolkit ----
echo ""; echo "=== Step 2/4: Docker + NVIDIA ===="
if ! command -v docker &>/dev/null; then
    sudo apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc 2>/dev/null || true
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -qq
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker --now
    sudo usermod -aG docker "$USER"
fi
ok "Docker $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"

# NVIDIA Container Toolkit
if ! command -v nvidia-ctk &>/dev/null; then
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey -o /tmp/nv-key
    sudo cp /tmp/nv-key /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    sudo chmod a+r /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -sL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sed 's/\$(ARCH)/amd64/g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
    sudo apt update -qq
    sudo apt install -y nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
fi
ok "NVIDIA CTK $(nvidia-ctk --version | head -1 | cut -d' ' -f5)"

# ---- Phase 3: Docker proxy (for China users) ----
echo ""; echo "=== Step 3/4: Docker Proxy (optional) ==="
PROXY_PORT=7897
if ss -tlnp 2>/dev/null | grep -q ":$PROXY_PORT"; then
    sudo mkdir -p /etc/systemd/system/docker.service.d
    sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null << EOF
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:${PROXY_PORT}"
Environment="HTTPS_PROXY=http://127.0.0.1:${PROXY_PORT}"
Environment="NO_PROXY=localhost,127.0.0.1,::1"
EOF
    sudo systemctl daemon-reload && sudo systemctl restart docker
    ok "Docker proxy configured (127.0.0.1:$PROXY_PORT)"
else
    note "No proxy detected on port $PROXY_PORT — skipping Docker proxy setup"
fi

# ---- Phase 4: ROS 2 Lyrical Luth ----
echo ""; echo "=== Step 4/4: ROS 2 Lyrical Luth ==="
if [ ! -d /opt/ros/lyrical ] 2>/dev/null; then
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /tmp/ros.key
    sudo cp /tmp/ros.key /usr/share/keyrings/ros-archive-keyring.gpg
    sudo chmod a+r /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
    sudo apt update -qq
    sudo apt install -y ros-lyrical-desktop python3-colcon-common-extensions python3-rosdep
    sudo rosdep init 2>/dev/null || true
    rosdep update 2>/dev/null || true
fi
ok "ROS 2 Lyrical Luth installed"

echo ""
echo "========================================="
echo " System setup complete!"
echo ""
echo " Next: bash scripts/setup_miniconda.sh"
echo ""
echo " ⚠️  Run 'newgrp docker' or re-login for Docker group to take effect."
echo "========================================="
