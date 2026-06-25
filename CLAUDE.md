# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Identity
This is a **Unitree G1 humanoid robot reinforcement learning** tutorial and development project.
**Goal**: Help beginners set up Isaac Lab/Isaac Sim for G1 RL training, maintain environment documentation.

## Host System
- Ubuntu 26.04, AMD Ryzen 7 6800HS, NVIDIA RTX 3080 Ti 16GB, driver **580.159.03** / CUDA 13.2
- 14GB RAM, 300GB NVMe (~238GB free after Isaac Sim)

## Stack
- **Simulation**: Isaac Sim 5.1.0 via Docker NGC (`nvcr.io/nvidia/isaac-sim:5.1.0`, ~23GB)
- **Python**: Miniconda (`env_isaaclab`=3.10, `env_ros`=3.12) — host Python 3.14 NEVER used
- **ROS**: ROS 2 Lyrical Luth (native Ubuntu 26.04, at `/opt/ros/lyrical/`)
- **RL**: RSL-RL (`rsl-rl-lib==5.0.1`, installed to persistent pip_pkgs)
- **GPU**: NVIDIA Container Toolkit 1.19.1

## Directory Layout
```
~/projects/g1-rl/
├── configs/             # 用户参数配置文件 (g1_config.py)
├── workspace/           # Docker mount → /workspace inside container
├── sim/                 # Cloned repos (unitree_rl_lab, unitree_ros, IsaacLab) — gitignored
├── scripts/             # 3 scripts committed to GitHub
├── docs/                # 3 beginner tutorials in Chinese
├── 0_getting_started/   # Beginner tutorials (terminal, git, RL intro)
├── 1_environment/       # Setup tutorials (Docker, GPU, proxy)
├── 2_fundamentals/      # Python, Jupyter, PyTorch, RL theory
├── 3_g1_project/        # G1 training: architecture, config, play, troubleshooting
├── 4_advanced/          # Git collab, Docker build, multi-machine deploy
├── notebooks/           # Interactive Jupyter notebooks
├── showcase/            # Training results: GIFs, screenshots (filename=description)
├── docs/                # Project docs: training log, hardware profile, failure analysis
├── workspace/           # Docker mount → /workspace inside container
├── sim/                 # Cloned repos (unitree_rl_lab, unitree_ros, IsaacLab) — gitignored
├── scripts/             # 3 scripts committed to GitHub
├── models/ logs/ data/ deploy/   # Runtime dirs, gitignored
```

Single source of truth in this repo: `0_getting_started/` + `1_environment/` + `2_fundamentals/` + `3_g1_project/` + `4_advanced/` + `scripts/` + `README.md` (Chinese beginner tutorials).
`sim/`, `workspace/`, `models/`, `logs/` are runtime artifacts and NOT committed.

## Key Commands

```bash
# System setup (one-time)
bash scripts/setup_system.sh         # git/docker/nvidia-ctk/ros2 + docker proxy

# Conda environments
bash scripts/setup_miniconda.sh      # env_isaaclab (3.10) + env_ros (3.12)

# Isaac Sim container
bash scripts/launch_isaac_sim.sh     # interactive shell, mounts workspace + sim repos

# === G1 RL training workflow (core) ===
cd ~/projects/g1-rl

# Install training deps (one-time, or after pip_pkgs cleared)
bash scripts/start.sh install

# 所有训练参数在 configs/g1_config.py 中配置，按功能分为：
#   TrainConfig  — train / train-gui / resume 共用 (task, num_envs, max_iterations, seed)
#   PlayConfig   — play 专用 (task, num_envs)
# 修改后直接生效，不需要环境变量或 CLI 参数

# Headless training (fast, no GUI)
bash scripts/start.sh train

# GUI training (see robots in real-time)
bash scripts/start.sh train-gui

# Resume interrupted training (interactive checkpoint selection)
bash scripts/start.sh resume

# Playback trained model
bash scripts/start.sh play <run_dir> <checkpoint>

# TensorBoard (monitor training curves)
tensorboard --logdir ~/projects/g1-rl/logs/rsl_rl/unitree_g1_29dof_velocity --bind_all --port 6006

# Quick verification
nvidia-smi                           # GPU driver OK (must be 580.x!)
sudo docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi  # Docker GPU OK
conda env list                       # 3 environments present
source /opt/ros/lyrical/setup.bash && ros2 -h  # ROS 2 OK
```

## Architecture: How Components Connect

```
Docker (Isaac Sim 5.1.0) → /isaac-sim/ (sim platform)
                             /workspace/ ← ~/projects/g1-rl/workspace
                             /sim/      ← ~/projects/g1-rl/sim
Conda env_isaaclab (3.10)  → Isaac Lab RL training (inside Docker)
Conda env_ros (3.12)       → ROS 2 Lyrical Luth (native host)
NVIDIA CTK                  → Docker --gpus all --user 0:0 passthrough
Clash Verge :7897           → Docker daemon HTTP_PROXY + Git SSH ProxyCommand
```

## Critical Docker Configuration

**`--user 0:0` is REQUIRED** in all `docker run` commands. Without it:
- Container runs as `isaac-sim` user (uid=1234), which cannot write to `/root/.cache/*` (700)
- Shader cache, data store, Python node cache all fail with Permission denied
- Result: **black viewport in GUI mode** (HydraEngine rtx fails to create scene renderer)

`start.sh` has this configured: `DOCKER_BASE="docker run --rm --gpus all --user 0:0 ..."`

## rsl-rl-lib 5.0.1 Compatibility Fixes (3 files patched)

### 1. cli_args.py — parse_rsl_rl_cfg() must call handle_deprecated_rsl_rl_cfg()
**Why:** The `RslRlMLPModelCfg` dataclass has deprecated `stochastic=MISSING` field. Without calling `handle_deprecated_rsl_rl_cfg()`, `to_dict()` serializes `stochastic` into the dict, and rsl-rl 5.x's `MLPModel.__init__()` rejects it.
**Where:** `sim/unitree_rl_lab/scripts/rsl_rl/cli_args.py:59-63`

### 2. play.py — PPO API renamed in rsl-rl 5.x
**Why:** `PPO.policy` renamed to `PPO.actor`; `PPO.actor_critic` removed entirely.
**Where:** `sim/unitree_rl_lab/scripts/rsl_rl/play.py:132-150`
Also: use `runner.export_policy_to_jit/onnx()` (built-in in 5.x) instead of old manual export.

### 3. IsaacLab compat layer — hasattr guard for stochastic
**Why:** `_update_distribution_cfg()` at `utils.py:308` accesses `model_cfg.stochastic` without checking existence. Critic models (deterministic) have `distribution_cfg=None` and no `stochastic` attr.
**Where:** `sim/IsaacLab/source/isaaclab_rl/isaaclab_rl/rsl_rl/utils.py:309`
Change: `elif model_cfg.stochastic is True:` → `elif hasattr(model_cfg, "stochastic") and model_cfg.stochastic is True:`

### 4. train.py — duplicate deprecation handler cleaned up
**Where:** `sim/unitree_rl_lab/scripts/rsl_rl/train.py:131-133`
train.py had two identical `handle_deprecated_rsl_rl_cfg()` calls, reduced to one.

**IMPORTANT:** If you re-clone unitree_rl_lab or IsaacLab, re-apply all 4 fixes.

## User Configuration

**所有用户可调参数**: `configs/g1_config.py` — 按功能划分为 TrainConfig 和 PlayConfig。

- `TrainConfig`: task, num_envs (默认4096), max_iterations (默认50000), seed (默认43，-1=随机)
- `PlayConfig`: task, num_envs (默认32)

修改后直接生效。不要用环境变量 `TRAIN_NUM_ENVS` / `TRAIN_MAX_ITER` / `TRAIN_SEED`（已删除）。

## Terrain/Scene Configuration

Config file: `sim/unitree_rl_lab/source/unitree_rl_lab/unitree_rl_lab/tasks/locomotion/robots/g1/29dof/velocity_env_cfg.py`

- `COBBLESTONE_ROAD_CFG` (line 46): Default terrain gen config (training + play both inherit)
  - `size=(1.0, 1.0)`: Each sub-terrain is 1×1m (compact for quick training)
  - `num_rows=3, num_cols=3`: 3×3 terrain grid
  - `border_width=2.0`: Flat border around terrain (minimal)
  - Total area = `(num_cols × size[1] + 2×border) × (num_rows × size[0] + 2×border)`
- `RobotEnvCfg.scene.num_envs=4096` (line 413): Training env count (overridden by `configs/g1_config.py` TrainConfig.num_envs)
- `RobotPlayEnvCfg` (line 465): Overrides for playback — `num_envs=4`, terrain `6×6`

## Network (China-specific)
This machine sits behind the GFW. Two proxy layers exist:
1. **Docker daemon**: `HTTP_PROXY=http://127.0.0.1:7897` at `/etc/systemd/system/docker.service.d/http-proxy.conf`
2. **Git SSH**: `ProxyCommand nc -X connect -x 127.0.0.1:7897 %h %p` at `~/.ssh/config`

Both depend on Clash Verge (`verge-mihomo`) running on port 7897. If GitHub/Docker Hub are unreachable, check `ss -tlnp | grep 7897` first.

## Dependency Repos (not committed)
- `~/projects/g1-rl/sim/unitree_rl_lab/` — https://github.com/unitreerobotics/unitree_rl_lab
- `~/projects/g1-rl/sim/unitree_ros/` — https://github.com/unitreerobotics/unitree_ros
- `~/projects/g1-rl/sim/IsaacLab/` — https://github.com/isaac-sim/IsaacLab (cloned locally for reference/fixes)

## Compatibility Constraints
- **Ubuntu 26.04 > Isaac Sim official support (22.04/24.04)** → Docker is mandatory, never attempt native install
- **Host Python 3.14** → Isaac Sim needs 3.10, always use Conda
- **GPU driver 580.x required** for Isaac Sim 5.1.0 (595.x causes segfault in librtx.scenedb.plugin.so)
- **Docker `--user 0:0` mandatory** — shader/ogn caches fail without root
- **Docker group**: user must be in `docker` group, or use `sudo` for all Docker commands
