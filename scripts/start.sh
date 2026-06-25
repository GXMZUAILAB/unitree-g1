#!/bin/bash
# =============================================================================
# G1 RL Training Launcher — v2.0
# =============================================================================
# Architecture:
#   - Config file values (velocity_env_cfg.py) are the SOURCE OF TRUTH
#   - Env vars (TRAIN_NUM_ENVS, etc.) OVERRIDE config — only when YOU set them
#   - If you don't set an env var, the config file value is used unchanged
#   - Interactive menus auto-discover available models — no blind path typing
#
# Quick start:
#   bash scripts/start.sh              # interactive menu
#   TRAIN_NUM_ENVS=4096 bash scripts/start.sh train   # one-liner
#   bash scripts/start.sh play         # auto-lists checkpoints for you
#   bash scripts/start.sh resume       # resume interrupted training
# =============================================================================
set -euo pipefail

# ── User-overridable defaults ─────────────────────────────────────────────
# TRAIN_NUM_ENVS  — if set, overrides config file's scene.num_envs
# TRAIN_MAX_ITER  — if set, overrides agent config's max_iterations
# TRAIN_TASK      — task name (default: Unitree-G1-29dof-Velocity)
# TRAIN_SEED      — random seed (-1 = random)
# TRAIN_HEADLESS  — set to 0 for GUI mode (train-gui)
TRAIN_TASK="${TRAIN_TASK:-Unitree-G1-29dof-Velocity}"

# ── Docker / paths ────────────────────────────────────────────────────────
IMAGE="nvcr.io/nvidia/isaac-sim:5.1.0"
SIM_DIR="${HOME}/projects/g1-rl/sim"
CACHE_DIR="${HOME}/.cache/isaac-sim"
LOG_DIR="${HOME}/projects/g1-rl/logs"
PIP_PKGS_DIR="${CACHE_DIR}/pip_pkgs"
PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"

EXTRA_PYTHONPATH="/sim/IsaacLab/source/isaaclab:/sim/IsaacLab/source/isaaclab_rl:/sim/IsaacLab/source/isaaclab_tasks:/isaac-sim/pip_pkgs:/sim/unitree_rl_lab/source/unitree_rl_lab"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

# ── One-time setup ────────────────────────────────────────────────────────
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

# ── Helper: build CLI args from env vars ──────────────────────────────────
# Only passes flags when env var is set → config file values are preserved
build_train_args() {
    local args=""
    args="${args} --task ${TRAIN_TASK}"
    [[ -n "${TRAIN_NUM_ENVS:-}" ]] && args="${args} --num_envs ${TRAIN_NUM_ENVS}"
    [[ -n "${TRAIN_MAX_ITER:-}" ]] && args="${args} --max_iterations ${TRAIN_MAX_ITER}"
    [[ -n "${TRAIN_SEED:-}" ]]   && args="${args} --seed ${TRAIN_SEED}"
    echo "${args}"
}

# ── Helpers: run Python inside Docker ─────────────────────────────────────
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

# ── list_runs: discover available training runs ───────────────────────────
list_runs() {
    local log_root="${LOG_DIR}/rsl_rl/unitree_g1_29dof_velocity"
    if [[ ! -d "${log_root}" ]]; then
        echo -e "${RED}No training runs found in ${log_root}${NC}"
        return 1
    fi
    local runs=()
    while IFS= read -r d; do
        runs+=("$(basename "$d")")
    done < <(ls -1dt "${log_root}"/ 2>/dev/null)
    echo "${runs[@]}"
}

# ── list_checkpoints: list model files in a run dir ───────────────────────
list_checkpoints() {
    local run_dir="${1}"
    local log_root="${LOG_DIR}/rsl_rl/unitree_g1_29dof_velocity/${run_dir}"
    if [[ ! -d "${log_root}" ]]; then
        echo -e "${RED}Run directory not found: ${log_root}${NC}"
        return 1
    fi
    ls -1t "${log_root}"/model_*.pt 2>/dev/null | while read -r f; do
        basename "$f"
    done
}

# ── select_run: interactive run selection ─────────────────────────────────
select_run() {
    local log_root="${LOG_DIR}/rsl_rl/unitree_g1_29dof_velocity"
    if [[ ! -d "${log_root}" ]]; then
        echo -e "${RED}No training runs found.${NC}"
        return 1
    fi
    local runs=()
    while IFS= read -r d; do
        [[ -n "$d" ]] && runs+=("$d")
    done < <(ls -1dt "${log_root}"/ 2>/dev/null)

    if [[ ${#runs[@]} -eq 0 ]]; then
        echo -e "${RED}No training runs found.${NC}"
        return 1
    fi

    echo ""
    echo -e "${BLUE}=== Available Training Runs ===${NC}"
    local i=1
    for r in "${runs[@]}"; do
        local ckpt_count=$(ls -1 "${log_root}/${r}"/model_*.pt 2>/dev/null | wc -l)
        # Show when the run was created (dir name is the timestamp)
        echo -e "  ${GREEN}${i}${NC} -> ${CYAN}${r}${NC}  (${ckpt_count} checkpoints)"
        ((i++))
    done
    echo ""

    local choice
    while true; do
        echo -n "  Select run (1-${#runs[@]}): "
        read -r choice
        if [[ "${choice}" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#runs[@]} )); then
            echo "${runs[$((choice - 1))]}"
            return 0
        fi
        echo -e "  ${RED}Invalid choice, try again.${NC}"
    done
}

# ── select_checkpoint: interactive checkpoint selection ───────────────────
select_checkpoint() {
    local run_name="${1}"
    local log_root="${LOG_DIR}/rsl_rl/unitree_g1_29dof_velocity/${run_name}"
    local ckpts=()
    while IFS= read -r f; do
        ckpts+=("$(basename "$f")")
    done < <(ls -1t "${log_root}"/model_*.pt 2>/dev/null)

    if [[ ${#ckpts[@]} -eq 0 ]]; then
        echo -e "${RED}No checkpoints found in ${run_name}${NC}"
        return 1
    fi

    # Show most recent 20
    local show_n=20
    if (( ${#ckpts[@]} < show_n )); then show_n=${#ckpts[@]}; fi

    echo ""
    echo -e "${BLUE}=== Checkpoints in ${CYAN}${run_name}${BLUE} ===${NC}"
    echo -e "  (showing most recent ${show_n} of ${#ckpts[@]} total)"
    local i=1
    while (( i <= show_n )); do
        echo -e "  ${GREEN}${i}${NC} -> ${ckpts[$((i - 1))]}"
        ((i++))
    done
    echo ""

    local choice
    while true; do
        echo -n "  Select checkpoint (1-${show_n}): "
        read -r choice
        if [[ "${choice}" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= show_n )); then
            echo "${ckpts[$((choice - 1))]}"
            return 0
        fi
        echo -e "  ${RED}Invalid choice, try again.${NC}"
    done
}

# =============================================================================
# Commands
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

train() {
    local extra_args="$(build_train_args)"
    echo -e "${GREEN}=== G1 RL Training (headless) ===${NC}"
    if [[ -n "${TRAIN_NUM_ENVS:-}" ]]; then
        echo "Envs: ${TRAIN_NUM_ENVS} (env var override)"
    else
        echo -e "Envs: from config file (use TRAIN_NUM_ENVS=4096 to override)"
        echo -e "${YELLOW}⚠  Config default is 16384 envs — may crash on <32GB RAM.${NC}"
        echo -e "${YELLOW}   Recommended: TRAIN_NUM_ENVS=4096 for 16GB VRAM / 14GB RAM${NC}"
    fi
    if [[ -n "${TRAIN_MAX_ITER:-}" ]]; then
        echo "Iter: ${TRAIN_MAX_ITER}"
    fi
    echo ""
    run_python "/sim/unitree_rl_lab/scripts/rsl_rl/train.py ${extra_args} --headless"
    echo -e "${GREEN}Done. Models: ${LOG_DIR}/rsl_rl/unitree_g1_29dof_velocity/${NC}"
}

train_gui() {
    local extra_args="$(build_train_args)"
    echo -e "${GREEN}=== G1 RL Training (GUI) ===${NC}"
    if [[ -n "${TRAIN_NUM_ENVS:-}" ]]; then
        echo "Envs: ${TRAIN_NUM_ENVS} (CLI override)"
    else
        echo "Envs: from config file"
    fi
    echo -e "${YELLOW}Opening Isaac Sim 3D — close window or Ctrl+C to stop.${NC}"
    run_python_gui "/sim/unitree_rl_lab/scripts/rsl_rl/train.py ${extra_args}"
    echo -e "${GREEN}Done. Models: ${LOG_DIR}/rsl_rl/unitree_g1_29dof_velocity/${NC}"
}

resume() {
    # Pick run and checkpoint interactively
    local run_name=$(select_run) || return 1
    local checkpoint=$(select_checkpoint "${run_name}") || return 1

    local extra_args="$(build_train_args)"
    echo ""
    echo -e "${GREEN}=== Resuming Training ===${NC}"
    echo "Run:        ${run_name}"
    echo "Checkpoint: ${checkpoint}"
    echo ""
    run_python "/sim/unitree_rl_lab/scripts/rsl_rl/train.py \
        ${extra_args} --headless \
        --resume \
        --load_run ${run_name} \
        --checkpoint ${checkpoint}"
    echo -e "${GREEN}Done.${NC}"
}

play() {
    local run_name="${1:-}"
    local checkpoint="${2:-}"
    local play_num_envs="${PLAY_NUM_ENVS:-32}"

    # If no args, interactive selection
    if [[ -z "${run_name}" ]] || [[ "${run_name}" == "none" ]]; then
        run_name=$(select_run) || return 1
    fi
    if [[ -z "${checkpoint}" ]] || [[ "${checkpoint}" == "none" ]]; then
        checkpoint=$(select_checkpoint "${run_name}") || return 1
    fi

    echo ""
    echo -e "${GREEN}=== Playback ===${NC}"
    echo "Run:        ${run_name}"
    echo "Checkpoint: ${checkpoint}"
    echo "Envs:       ${play_num_envs}"
    echo -e "${YELLOW}Opening Isaac Sim 3D — close window or Ctrl+C to stop.${NC}"
    echo ""
    run_python_gui "/sim/unitree_rl_lab/scripts/rsl_rl/play.py \
        --task ${TRAIN_TASK} \
        --num_envs ${play_num_envs} \
        --load_run ${run_name} \
        --checkpoint ${checkpoint}"
    echo -e "${GREEN}Done.${NC}"
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

shell() {
    echo -e "${GREEN}=== Interactive Shell ===${NC}"
    echo "python3 ready after: source /isaac-sim/setup_python_env.sh"
    ${DOCKER_BASE} -it \
        -e "PYTHONPATH=\${PYTHONPATH}:${EXTRA_PYTHONPATH}" \
        -e "EXP_PATH=/sim/IsaacLab/apps" \
        --entrypoint bash "${IMAGE}"
}

# =============================================================================
# Main
# =============================================================================
case "${1:-menu}" in
    install|i)             install ;;
    visualize|gui|vis|v)   visualize ;;
    train|t)               train ;;
    train-gui|tg)          train_gui ;;
    resume|r)              resume ;;
    play|p)                play "${2:-}" "${3:-}" ;;
    shell|s|bash|sh)       shell ;;
    tensorboard|tb)
        echo -e "${GREEN}=== TensorBoard ===${NC}"
        echo "Open http://localhost:6006 in browser"
        tensorboard --logdir "${LOG_DIR}/rsl_rl/unitree_g1_29dof_velocity" --bind_all --port 6006
        ;;
    menu|m|"")
        # Show current config status
        local num_envs_info="from config file"
        local max_iter_info="from config file"
        [[ -n "${TRAIN_NUM_ENVS:-}" ]] && num_envs_info="${TRAIN_NUM_ENVS}"
        [[ -n "${TRAIN_MAX_ITER:-}" ]] && max_iter_info="${TRAIN_MAX_ITER}"

        echo ""
        echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║     G1 RL Training Launcher v2.0        ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${GREEN}1${NC}  train          RL training (headless)"
        echo -e "  ${GREEN}2${NC}  train-gui      RL training + live 3D view"
        echo -e "  ${GREEN}3${NC}  resume         Resume interrupted training"
        echo -e "  ${GREEN}4${NC}  play           Playback trained model"
        echo -e "  ${GREEN}5${NC}  visualize      3D GUI - explore the scene"
        echo -e "  ${GREEN}6${NC}  shell          Interactive container shell"
        echo -e "  ${GREEN}7${NC}  install        Install dependencies (run once first!)"
        echo -e "  ${GREEN}8${NC}  tensorboard    Monitor training curves"
        echo ""
        echo -e "  ${CYAN}Task:${NC}  ${TRAIN_TASK}"
        echo -e "  ${CYAN}Envs:${NC}  ${num_envs_info}"
        echo -e "  ${CYAN}Iter:${NC}  ${max_iter_info}"
        echo ""
        echo -e "  ${YELLOW}Usage:${NC} TRAIN_NUM_ENVS=4096 bash scripts/start.sh train"
        echo -e "  ${YELLOW}Play:${NC}  PLAY_NUM_ENVS=4 bash scripts/start.sh play"
        echo ""
        echo -n "  Choice (1-8): "
        read -r choice
        case "${choice}" in
            1|train|t)               train ;;
            2|train-gui|tg)          train_gui ;;
            3|resume|r)              resume ;;
            4|play|p)
                echo -e "${YELLOW}Select model to play:${NC}"
                local rd=$(select_run) || exit 1
                local ck=$(select_checkpoint "${rd}") || exit 1
                play "${rd}" "${ck}"
                ;;
            5|visualize|gui|vis|v)  visualize ;;
            6|shell|s|bash|sh)       shell ;;
            7|install|i)             install ;;
            8|tensorboard|tb)
                tensorboard --logdir "${LOG_DIR}/rsl_rl/unitree_g1_29dof_velocity" --bind_all --port 6006
                ;;
            *) echo -e "${RED}Unknown: ${choice}${NC}" ;;
        esac
        ;;
    *)
        echo "Usage: bash scripts/start.sh [train|train-gui|resume|play|visualize|shell|install|tensorboard]"
        echo ""
        echo "Env vars (optional — only set to override config file values):"
        echo "  TRAIN_NUM_ENVS=4096   # override scene.num_envs"
        echo "  TRAIN_MAX_ITER=20000  # override max_iterations"
        echo "  TRAIN_SEED=42         # set random seed (-1 = random)"
        echo ""
        echo "Examples:"
        echo "  bash scripts/start.sh train              # use config file defaults"
        echo "  TRAIN_NUM_ENVS=4096 bash scripts/start.sh train  # override num_envs"
        echo "  bash scripts/start.sh play               # interactive model selection"
        echo "  bash scripts/start.sh resume             # resume from checkpoint"
        exit 1 ;;
esac
