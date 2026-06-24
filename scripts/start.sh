#!/bin/bash
# =============================================================================
# G1 RL Training Launcher
# =============================================================================
set -euo pipefail

TRAIN_TASK="${TRAIN_TASK:-Unitree-G1-29dof-Velocity}"
TRAIN_NUM_ENVS="${TRAIN_NUM_ENVS:-4}"
TRAIN_MAX_ITER="${TRAIN_MAX_ITER:-20000}"

IMAGE="nvcr.io/nvidia/isaac-sim:5.1.0"
SIM_DIR="${HOME}/projects/g1-rl/sim"
CACHE_DIR="${HOME}/.cache/isaac-sim"
LOG_DIR="${HOME}/projects/g1-rl/logs"
PIP_PKGS_DIR="${CACHE_DIR}/pip_pkgs"
PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"

# Extra paths appended AFTER Isaac Sim's own PYTHONPATH
EXTRA_PYTHONPATH="/sim/IsaacLab/source/isaaclab:/sim/IsaacLab/source/isaaclab_rl:/sim/IsaacLab/source/isaaclab_tasks:/isaac-sim/pip_pkgs:/sim/unitree_rl_lab/source/unitree_rl_lab"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

mkdir -p "${CACHE_DIR}"/{kit,ov,pip,glcache,computecache,logs,data,documents}
mkdir -p "${PIP_PKGS_DIR}"
mkdir -p "${LOG_DIR}"

DOCKER_BASE="docker run --rm --gpus all --user 0:0 \
  -e ACCEPT_EULA=Y -e OMNI_KIT_ACCEPT_EULA=YES -e OMNI_KIT_ALLOW_ROOT=1 \
  -e PRIVACY_CONSENT=Y \
  -e GIT_PYTHON_REFRESH=quiet \
  --shm-size=8g --network=host \
  -v /usr/bin/git:/usr/bin/git:ro \
  -v ${CACHE_DIR}/kit:/isaac-sim/kit/cache:rw \
  -v ${CACHE_DIR}/ov:/root/.cache/ov:rw \
  -v ${CACHE_DIR}/pip:/root/.cache/pip:rw \
  -v ${CACHE_DIR}/glcache:/root/.cache/nvidia/GLCache:rw \
  -v ${CACHE_DIR}/computecache:/root/.nv/ComputeCache:rw \
  -v ${CACHE_DIR}/logs:/root/.nvidia-omniverse/logs:rw \
  -v ${CACHE_DIR}/data:/root/.local/share/ov/data:rw \
  -v ${PIP_PKGS_DIR}:/isaac-sim/pip_pkgs:rw \
  -v ${SIM_DIR}:/sim:rw \
  -v ${LOG_DIR}:/isaac-sim/logs:rw"

ENV_WRAPPER="export GIT_PYTHON_REFRESH=quiet \
  && source /isaac-sim/setup_python_env.sh \
  && export CARB_APP_PATH=/isaac-sim/kit \
  && export ISAAC_PATH=/isaac-sim \
  && export EXP_PATH=/isaac-sim/apps \
  && export LD_PRELOAD=/isaac-sim/kit/libcarb.so \
  && export RESOURCE_NAME=IsaacSim \
  && export PYTHONPATH=\${PYTHONPATH}:${EXTRA_PYTHONPATH}"

# Run python with full Isaac Sim environment
run_python() {
    ${DOCKER_BASE} \
        --entrypoint bash "${IMAGE}" \
        -c "${ENV_WRAPPER} && /isaac-sim/kit/python/bin/python3 $@" 2>&1
}

run_python_gui() {
    xhost +local: 2>/dev/null
    ${DOCKER_BASE} \
        -e "DISPLAY=${DISPLAY}" \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v "${HOME}/.Xauthority:/root/.Xauthority:ro" \
        --entrypoint bash "${IMAGE}" \
        -c "${ENV_WRAPPER} && /isaac-sim/kit/python/bin/python3 $@" 2>&1
}

# =============================================================================
install() {
    echo -e "${GREEN}=== Installing training dependencies (persistent) ===${NC}"
    echo "Packages go to: ${PIP_PKGS_DIR}"
    echo ""

    ${DOCKER_BASE} --entrypoint bash "${IMAGE}" -c "
set -e
source /isaac-sim/setup_python_env.sh
export CARB_APP_PATH=/isaac-sim/kit
export ISAAC_PATH=/isaac-sim
export EXP_PATH=/isaac-sim/apps
export LD_PRELOAD=/isaac-sim/kit/libcarb.so
export PYTHONPATH=\${PYTHONPATH}:${EXTRA_PYTHONPATH}
export PATH=/isaac-sim/kit/python/bin:\$PATH

echo 'Step 0: Cleaning any conflicting pip isaaclab...'
rm -rf /isaac-sim/pip_pkgs/isaaclab /isaac-sim/pip_pkgs/isaaclab*.dist-info 2>/dev/null || true

echo 'Step 1: Installing gymnasium + rsl-rl-lib==5.0.1 + argcomplete...'
python3 -m pip install --target /isaac-sim/pip_pkgs -i ${PIP_MIRROR} gymnasium rsl-rl-lib==5.0.1 argcomplete 2>&1 | tail -3

echo 'Step 2: Linking unitree_rl_lab...'
echo '/sim/unitree_rl_lab/source/unitree_rl_lab' > /isaac-sim/pip_pkgs/unitree_rl_lab.pth

echo ''
echo 'Packages on disk:'
ls /isaac-sim/pip_pkgs/ | head -20
echo ''
echo 'All dependencies installed.'
" 2>&1

    echo -e "${GREEN}Install complete.${NC}"
}

# =============================================================================
train() {
    echo -e "${GREEN}=== G1 RL Training (headless) ===${NC}"
    echo "Task: ${TRAIN_TASK}  Envs: ${TRAIN_NUM_ENVS}  Iter: ${TRAIN_MAX_ITER}"
    run_python "/sim/unitree_rl_lab/scripts/rsl_rl/train.py --task ${TRAIN_TASK} --num_envs ${TRAIN_NUM_ENVS} --max_iterations ${TRAIN_MAX_ITER} --headless"
    echo -e "${GREEN}Done. Models: ${LOG_DIR}${NC}"
}

train_gui() {
    echo -e "${GREEN}=== G1 RL Training (GUI) ===${NC}"
    echo "Task: ${TRAIN_TASK}  Envs: ${TRAIN_NUM_ENVS}  Iter: ${TRAIN_MAX_ITER}"
    echo -e "${YELLOW}Opening Isaac Sim 3D — close window or Ctrl+C to stop.${NC}"
    run_python_gui "/sim/unitree_rl_lab/scripts/rsl_rl/train.py --task ${TRAIN_TASK} --num_envs ${TRAIN_NUM_ENVS} --max_iterations ${TRAIN_MAX_ITER}"
    echo -e "${GREEN}Done. Models: ${LOG_DIR}${NC}"
}

visualize() {
    echo -e "${GREEN}=== G1 Visualization ===${NC}"
    echo "Opening Isaac Sim 3D editor..."
    xhost +local: 2>/dev/null
    ${DOCKER_BASE} \
        -e "DISPLAY=${DISPLAY}" \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v "${HOME}/.Xauthority:/root/.Xauthority:ro" \
        --entrypoint /isaac-sim/runapp.sh "${IMAGE}"
    echo -e "${GREEN}GUI closed.${NC}"
}

play() {
    local run_dir="${1:-none}"
    local checkpoint="${2:-none}"
    echo -e "${GREEN}=== Playback: ${run_dir} / ckpt ${checkpoint} ===${NC}"
    run_python_gui "/sim/unitree_rl_lab/scripts/rsl_rl/play.py --task ${TRAIN_TASK} --num_envs 32 --load_run ${run_dir} --checkpoint /isaac-sim/logs/rsl_rl/unitree_g1_29dof_velocity/${run_dir}/${checkpoint}"
}

shell() {
    echo -e "${GREEN}=== Interactive Shell ===${NC}"
    echo "python3 ready after: source /isaac-sim/setup_python_env.sh"
    ${DOCKER_BASE} -it \
        -e "PYTHONPATH=\${PYTHONPATH}:${EXTRA_PYTHONPATH}" \
        -e "EXP_PATH=/sim/IsaacLab/apps" \
        --entrypoint bash "${IMAGE}"
}

# =============================================================================
case "${1:-menu}" in
    install|i)             install ;;
    visualize|gui|vis|v)   visualize ;;
    train|t)               train ;;
    train-gui|tg)          train_gui ;;
    play|p)                play "${2:-}" "${3:-}" ;;
    shell|s|bash|sh)       shell ;;
    menu|m|"")
        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}  G1 RL Training Launcher${NC}"
        echo -e "${BLUE}========================================${NC}"
        echo ""
        echo -e "  ${GREEN}1${NC} -> ${GREEN}visualize${NC}  3D GUI - see the G1 robot"
        echo -e "  ${GREEN}2${NC} -> ${GREEN}train${NC}      RL training (headless)"
        echo -e "  ${GREEN}3${NC} -> ${GREEN}train-gui${NC}  RL training + live 3D view"
        echo -e "  ${GREEN}4${NC} -> ${GREEN}play${NC}       Playback trained model"
        echo -e "  ${GREEN}5${NC} -> ${GREEN}shell${NC}      Interactive container shell"
        echo -e "  ${GREEN}6${NC} -> ${GREEN}install${NC}    Install dependencies (run once first!)"
        echo ""
        echo -e "  Task: ${TRAIN_TASK} / ${TRAIN_NUM_ENVS} envs / ${TRAIN_MAX_ITER} iter"
        echo -e "${BLUE}========================================${NC}"
        echo ""
        echo -n "  Choice (1-6): "
        read -r choice
        case "${choice}" in
            1|visualize|gui|vis|v)  visualize ;;
            2|train|t)               train ;;
            3|train-gui|tg)          train_gui ;;
            4|play|p)                echo -n "Run folder: "; read -r rd; echo -n "Checkpoint: "; read -r ck; play "${rd}" "${ck}" ;;
            5|shell|s|bash|sh)       shell ;;
            6|install|i)             install ;;
            *) echo "Unknown: ${choice}" ;;
        esac
        ;;
    *)
        echo "Usage: bash scripts/start.sh [visualize|train|train-gui|play|shell|install]"
        exit 1 ;;
esac
