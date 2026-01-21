# Project Context

## Purpose

This project aims to develop dance motion capabilities for the Unitree G1 humanoid robot using reinforcement learning. The primary goals are:

- Train the G1 robot to perform dance movements through motion imitation using RL algorithms
- Leverage Isaac Sim and Isaac Lab for high-fidelity physics simulation
- Implement a "VibeCoding" development paradigm where AI and humans collaborate through structured prompts and documentation
- Enable sim-to-real transfer for deployment on physical Unitree G1 robots

## Tech Stack

- **Simulation**: Isaac Sim (Standalone) + Isaac Lab (robotics RL framework)
- **Language**: Python 3.10+
- **ML Framework**: PyTorch (managed by Isaac Lab environment)
- **RL Libraries**: RSL\_RL (Rapid Skills Learning), PPO/AMP algorithms
- **Configuration**: Hydra (for experiment management and parameter configuration)
- **Robot SDK**: unitree-sdk2py (for sim-to-real deployment)
- **Utilities**: tqdm, tensorboard, matplotlib, pytest
- **Parameters**: params-proto==2.10.5

## Project Conventions

### Code Style

- Follow PEP 8 conventions for Python code
- Use meaningful variable names reflecting robotics domain (e.g., `joint_positions`, `reward_shaper`)
- Optional linters: black (formatting), flake8 (style checking)
- Document complex physics calculations and reward functions with inline comments
- Keep AI collaboration context in mind: clear, self-documenting code is critical

### Architecture Patterns

- **Modular Design**: Separate concerns into `envs/`, `algo/`, and `utils/` packages
- **Hydra Configuration**: All hyperparameters and environment settings managed via YAML configs in `configs/`
- **Isaac Lab Integration**: Extend Isaac Lab base classes for custom G1 environment
- **Reward Shaping**: Dedicated reward function modules in `unitree_rl/` for motion tracking
- **Observation Station Pattern**: Centralized sensor data processing and feature extraction

### Testing Strategy

- Use `pytest` for unit tests
- Validation through Isaac Sim simulation runs (visual inspection + metrics)
- Test reward functions in isolation before full training
- Maintain training logs with tensorboard for performance monitoring
- Simulation-based integration tests before sim-to-real transfer

### Git Workflow

- Feature branches for new capabilities (e.g., `add-arm-motion-tracking`)
- Document-driven development: update `docs/` before code changes
- Commit messages should reference task documents when applicable
- Keep prompts and docs in sync with code changes

## Domain Context

### Robotics Terminology

- **G1**: Unitree's humanoid robot platform (target hardware)
- **Motion Imitation**: RL technique to learn human-like movements from reference data (e.g., BVH files)
- **Sim2Real**: Transfer of policies trained in simulation to physical robots
- **PPO**: Proximal Policy Optimization (primary RL algorithm)
- **AMP**: Adversarial Motion Priors (for natural motion synthesis)

### Isaac Lab Workflow

- Isaac Lab provides the base environment and training infrastructure
- Custom environments extend `IsaacEnv` or similar base classes
- Training scripts use Isaac Lab's RL libraries (RSL\_RL)
- Simulation runs in headless mode for training, GUI mode for playback

### VibeCoding Paradigm

This project uses an AI-native collaboration model:

1. **Prompts (prompts/)**: Guide AI behavior and context
2. **Docs (docs/)**: Single source of truth for technical decisions
3. **Iteration Loop**: AI generates code → simulation validates → review prompts refine
4. AI assistants should always load relevant prompts and docs before generating code

## Important Constraints

### Technical Constraints

- **Isaac Lab Dependency**: Most ML and simulation dependencies are managed by Isaac Lab's environment; avoid version conflicts
- **GPU Required**: Training requires NVIDIA GPU with CUDA support
- **Simulation Fidelity**: Balance between realistic physics and training speed
- **Real Robot Limitations**: G1 has specific joint limits, torque constraints, and safety requirements

### Development Constraints

- Code must be compatible with Isaac Lab's plugin system
- Follow Isaac Lab's conventions for environment registration
- BVH motion files must be pre-processed and retargeted to G1's skeleton
- Maintain separation between simulation code and real robot deployment code

## External Dependencies

### Primary Systems

- **Isaac Sim**: NVIDIA's robotics simulation platform (physics engine, rendering)
- **Isaac Lab**: High-level RL framework built on Isaac Sim
- **Unitree SDK2**: Communication library for real G1 robot control

### Data Sources

- BVH motion capture data for dance sequences
- G1 robot URDF/USD models for simulation
- Pre-trained checkpoints (if using transfer learning)

### Services

- Tensorboard for training visualization (runs locally)
- Git/GitHub for version control and collaboration
