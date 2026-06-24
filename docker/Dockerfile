# =============================================================================
# G1 RL Training Docker Image
# =============================================================================
# Build:  docker build -f docker/Dockerfile -t g1-rl-train:latest .
# Run:    docker run --rm --gpus all --user 0:0 --network=host \
#           -e ACCEPT_EULA=Y -e OMNI_KIT_ALLOW_ROOT=1 \
#           -v ~/projects/g1-rl/logs:/isaac-sim/logs \
#           g1-rl-train:latest
# =============================================================================

FROM nvcr.io/nvidia/isaac-sim:5.1.0

# Isaac Sim already provides Python 3.10 at /isaac-sim/kit/python/bin/python3
# and PyTorch inside the container.

# Install RL training dependencies into persistent pip_pkgs directory
RUN /isaac-sim/kit/python/bin/python3 -m pip install \
    --target /isaac-sim/pip_pkgs \
    gymnasium \
    rsl-rl-lib==5.0.1 \
    argcomplete

# Copy project scripts and config into the container
COPY scripts/ /workspace/scripts/

# Make scripts executable
RUN chmod +x /workspace/scripts/*.sh

# Set up environment variables for Isaac Sim + RL training
ENV ACCEPT_EULA=Y \
    OMNI_KIT_ACCEPT_EULA=YES \
    OMNI_KIT_ALLOW_ROOT=1 \
    PYTHONPATH="/isaac-sim/pip_pkgs:/workspace" \
    CARB_APP_PATH=/isaac-sim/kit \
    ISAAC_PATH=/isaac-sim \
    EXP_PATH=/isaac-sim/apps

WORKDIR /workspace

# Default command: start interactive shell
# Override with: docker run ... g1-rl-train:latest bash scripts/start.sh train
CMD ["bash"]
