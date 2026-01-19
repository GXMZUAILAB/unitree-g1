# Unitree G1 强化学习舞蹈项目

本项目致力于为宇树 G1（Unitree G1）人形机器人开发强化学习（RL）策略，使其能够执行舞蹈和行走任务。

## 📂 项目结构

- **docs/**: **从这里开始 (START HERE)**。包含研究报告、硬件规格说明和环境搭建指南。
- **configs/**: 用于环境和资源强化学习训练的 Hydra 配置文件。
- **unitree\_rl/**: 核心源代码（环境、算法）。
- **scripts/**: 用于训练和回放的可执行脚本。
- **data/**: 存放动作数据集（如 AMASS 等）。

## 🚀 快速开始

1. **阅读研究报告**: `docs/research_report.md`
2. **搭建开发环境**: 严格按照 `docs/T1_环境与工具链搭建.md` 进行操作。

### 训练 (Training)

```bash
python scripts/train.py
```

覆盖参数示例：

```bash
python scripts/train.py train.learning_rate=0.0005
```

### 回放 (Playback)

```bash
python scripts/play.py checkpoint=path/to/model.pt
```

## 🛠 当前状态

- 项目结构已初始化
- 依赖项已定义
- 环境逻辑实现中 (开发中)
