# 🤖 Unitree G1 RL Dance Project

A high-fidelity reinforcement learning project for developing expressive dance motions on the Unitree G1 humanoid robot using NVIDIA Isaac Lab and the OpenSpec development framework.

---

## 🏗 Project Architecture

This project follows a structured, spec-driven development model using the **OpenSpec** framework. This ensures that every modification is well-planned, documented, and verifiable.

- **📦 unitree_rl/**: Core Python package containing environment definitions, reward functions, and utility modules.
- **⚙️ configs/**: Hydra-based configuration management for environments and RL algorithms.
- **🎨 assets/**: Unified storage for robot models (URDF/USD) and motion reference data (BVH).
- **📚 docs/**: Technical guides and research documentation.
- **📋 openspec/**: The "Source of Truth" for project requirements and change management.
- **🧪 scripts/**: Entry point scripts for training, evaluation, and visualization.
- **✅ tests/**: Automated test suites for core logic and environment physics.

---

## 🛠 Development Workflow (OpenSpec)

We use the OpenSpec framework to manage the lifecycle of features and changes:

1.  **Research**: Explore `openspec/project.md` and existing specs to understand the current state.
2.  **Propose**: Create a new change proposal in `openspec/changes/<id>/` defining the *Why*, *What*, and *How*.
3.  **Validate**: Use `openspec validate` to ensure the proposal meets project standards.
4.  **Implement**: Follow the `tasks.md` in the proposal to apply changes.
5.  **Archive**: Once deployed, archive the change to merge deltas into the core specifications.

> [!TIP]
> Always refer to `openspec/AGENTS.md` for detailed instructions on the spec-driven workflow.

---

## 🚀 Getting Started

### 1. Environment Setup
Follow the comprehensive setup guide in the documentation:
[📖 View T1: Implementation Guide](docs/T1_环境与工具链搭建.md)

### 2. Training
Launch the G1 dance training task using Isaac Lab:
```bash
python scripts/train.py task=G1_Dance
```

### 3. Playback
Visualize the trained policy in the Isaac Sim GUI:
```bash
python scripts/play.py task=G1_Dance checkpoint=latest
```

---

## 🛰 Roadmap

- [x] **Phase 1: Foundation** - Environment setup and Isaac Lab integration.
- [x] **Phase 2: Standardisation** - Transition to OpenSpec framework and project restructuring.
- [ ] **Phase 3: Motion Processing** - BVH retargeting and motion imitation logic.
- [ ] **Phase 4: Policy Training** - Optimizing PPO/AMP for natural dance motions.
- [ ] **Phase 5: Reality Gap** - Sim2Real validation on physical G1 hardware.

---

> [!NOTE]
> This project is governed by the OpenSpec protocol. Every requirement and scenario is defined in `openspec/specs/`.
