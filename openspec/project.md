# 项目上下文 (Project Context)

## 项目目标 (Purpose)

本项目旨在利用强化学习 (Reinforcement Learning) 为宇树 (Unitree) G1 人形机器人开发舞蹈动作能力。主要目标包括：

- 通过 RL 算法，利用动作模仿 (Motion Imitation) 训练 G1 机器人完成舞蹈动作
- 利用 Isaac Sim 和 Isaac Lab 进行高保真物理仿真
- 实施 **OpenSpec** 规格驱动开发范式，确保技术决策和需求的结构化管理
- 实现从仿真到实机 (Sim2Real) 的迁移，以便在物理 Unitree G1 机器人上部署

## 技术栈 (Tech Stack)

- **仿真 (Simulation)**: Isaac Sim (Standalone) + Isaac Lab (机器人 RL 框架)
- **语言 (Language)**: Python 3.10+
- **机器学习框架 (ML Framework)**: PyTorch (由 Isaac Lab 环境管理)
- **RL 库**: RSL_RL (Rapid Skills Learning), PPO/AMP 算法
- **配置 (Configuration)**: Hydra (用于实验管理和参数配置)
- **机器人 SDK**: unitree-sdk2py (用于 Sim2Real 部署)
- **工具库**: tqdm, tensorboard, matplotlib, pytest
- **参数管理**: params-proto==2.10.5
- **规格管理**: OpenSpec Framework

## 项目约定 (Project Conventions)

### 项目结构 (Project Structure)

- `assets/`: 统一存放机器人模型 (URDF/USD) 和动作捕捉参考数据 (BVH)
- `configs/`: 基于 Hydra 的参数管理，解耦算法与环境配置
- `docs/`: 存放技术指南、研究报告及设计文档
- `unitree_rl/`: 核心代码包，包含环境封装、奖励函数及工具类
- `openspec/`: 项目的“单一事实来源”，存放规格 (Specs) 和更改提案 (Changes)
- `scripts/`: 自动化训练、播放及数据处理脚本
- `tests/`: 单元测试与集成测试
- `resources/`: 存放 Prompts 等辅助性静态资源

### 代码风格 (Code Style)

- 遵循 Python 的 PEP 8 规范
- 使用反映机器人领域含义的变量名（例如 `joint_positions`, `reward_shaper`）
- 使用 OpenSpec 进行功能开发前的规格定义 (Spec-driven Development)
- 在代码中使用行内注释解释复杂的物理计算和 Reward 函数

### 架构模式 (Architecture Patterns)

- **模块化设计**: 将功能解耦到 `envs/`, `algo/`, 和 `utils/` 包中
- **Hydra 配置**: 所有超参数和环境设置均通过 `configs/` 中的 YAML 文件管理
- **Isaac Lab 集成**: 扩展 Isaac Lab 基类以实现自定义 G1 环境
- **规格驱动开发 (SDD)**: 任何重大变更必须先在 `openspec/changes/` 中提交提案

### 测试策略 (Testing Strategy)

- 使用 `pytest` 进行单元测试
- 通过 Isaac Sim 仿真运行进行验证（视觉检查 + 指标分析）
- 在完整训练前，独立测试 Reward 函数
- 使用 Tensorboard 维护训练日志以监控性能

### Git 工作流 (Git Workflow)

- 为新功能使用功能分支
- **OpenSpec 流程**: 提交提案 -> 验证通过 -> 执行任务 -> 归档规格
- 保持文档与代码同步更新

## 领域上下文 (Domain Context)

### 机器人术语 (Robotics Terminology)

- **G1**: 宇树 (Unitree) 的人形机器人平台
- **动作模仿 (Motion Imitation)**: 利用参考数据学习类人动作的 RL 技术
- **Sim2Real**: 将仿真策略迁移到物理机器人的过程

### Isaac Lab 工作流 (Isaac Lab Workflow)

- Isaac Lab 提供基础环境和训练基础设施
- 自定义环境扩展 `IsaacEnv` 或类似的基类
- 训练脚本使用 Isaac Lab 的 RL 库 (RSL_RL)

## 外部依赖 (External Dependencies)

- **Isaac Sim**: NVIDIA 的机器人仿真平台
- **Isaac Lab**: 基于 Isaac Sim 构建的高级 RL 框架
- **Unitree SDK2**: 用于物理 G1 机器人控制的通信库
- **Motion Capture Data**: 用于舞蹈序列的 BVH 文件
