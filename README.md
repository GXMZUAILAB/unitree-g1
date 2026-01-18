# Unitree G1 RL Dance Project

This project focuses on developing reinforcement learning policies for the Unitree G1 humanoid robot to perform dance and locomotion tasks.

## 📂 Project Structure

- **docs/**: **START HERE**. Contains research reports, hardware specs, and setup guides.
- **configs/**: Hydra configuration files for environments and RL training.
- **unitree\_rl/**: Core source code (environments, algorithms).
- **scripts/**: Executable scripts for training and playback.
- **data/**: Place your motion datasets (AMASS, etc.) here.

## 🚀 Getting Started

1. **Read the Research Report**: `docs/research_report.md`
2. **Setup Environment**: Follow `docs/setup_guide.md` strictly.

### Training

```bash
python scripts/train.py
```

To override parameters:

```bash
python scripts/train.py train.learning_rate=0.0005
```

### Playback

```bash
python scripts/play.py checkpoint=path/to/model.pt
```

## 🛠 Status

- Project Structure Initialized
- Dependencies Defined
- Environment Logic Implemented (In Progress)
