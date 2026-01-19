# Unitree G1 舞蹈机器人开发指南 (Main Development Guide)

这份指南为学生和研究人员提供了从零开始开发 Unitree G1 强化学习舞蹈项目的详细步骤。**本项目基于 NVIDIA Isaac Lab (Isaac Sim) 开发。**

## 1. 前置条件

- **操作系统**：Ubuntu 22.04 LTS (严格要求)
- **显卡**：NVIDIA RTX 3080 或更高 (显存 12GB+)
- **工具链**：
    - Isaac Sim 4.x / 5.x
    - Isaac Lab (Latest)
    - ROS2 Humble
    - Unitree SDK2
- **数据集**：AMASS / LAFAN1 (BVH 格式)

---

## 2. 核心技术任务分解

### TASK 01：环境与工具链搭建

**目标**：搭建基于 Isaac Lab 的开发环境并验证核心工具可用性。

1. **Isaac Sim**：通过 Omniverse Launcher 安装 Isaac Sim。
2. **Isaac Lab**：克隆并安装 Isaac Lab，配置 Python 环境。
3. **RSL_RL**：确保 RSL_RL 库在 Isaac Lab 环境中正确安装。
4. **SDK 与 ROS2**：安装宇树 SDK2 与 ROS2 Humble。

### TASK 02：运动数据准备与处理

**目标**：制备标准化 BVH 数据并转换为适配 Isaac Lab 的格式。

1. **数据筛选**：从 AMASS/LAFAN1 数据集提取 BVH 片段。
2. **动作重定向 (Retargeting)**：使用 Isaac Lab 提供的 retargeting 工具或自定义脚本，将人体动作映射到 G1 机器人的关节空间。
3. **资产转换**：将处理后的动作数据转换为 MJCF 或 USD 格式（如果需要），或者直接由 Python 脚本读取动作帧。
4. **验证**：在 Isaac Lab 中可视化重定向后的动作，验证无穿模和物理冲突。

### TASK 03：Isaac Lab 仿真环境配置

**目标**：在 Isaac Lab 中构建 G1 舞蹈任务环境。

1. **机器人资产**：配置 G1 的 USD/URDF 资产，设置正确的物理属性（刚体、碰撞体、关节驱动增益）。
2. **场景搭建**：创建平坦地面或舞台场景。
3. **Manager-Based RL 环境**：使用 Isaac Lab 的 Manager-Based 架构定义环境（Observation Manager, Reward Manager, Termination Manager）。
4. **动作追踪任务**：实现 `AMP` 或 `Tracking` 风格的任务逻辑，使机器人通过强化学习跟随参考动作。

### TASK 04：强化学习模型 (AMP/PPO) 训练

**目标**：在 Isaac Lab 中训练舞蹈策略。

1. **AMP/PHC 算法**：采用 AMP (Adversarial Motion Priors) 或类似的模仿学习算法，让机器人学习自然的舞蹈动作风格。
2. **PPO 配置**：配置 `rsl_rl` 的 PPO 超参数。
3. **训练启动**：调用 Isaac Lab 的训练脚本 (`train.py`) 开始大规模并行训练。
4. **复现验证**：在仿真中回放训练好的 Checkpoint，评估动作质量。

### TASK 05：强化学习模型迭代与仿真验证

**目标**：优化模型性能并验证其在仿真环境中的鲁棒性。

1. **域随机化 (Domain Randomization)**：在 Isaac Lab 中配置质量、摩擦力、延迟等物理参数的随机化，提高 Sim2Real 的鲁棒性。
2. **课程学习**：设计课程表，从简单动作逐步过渡到复杂舞蹈。
3. **稳定性确认**：长时间运行仿真，确保无 NaN 错误或物理爆炸。

### TASK 06：实物机器人指令适配

**目标**：搭建仿真输出与 G1 机器人可执行指令的通信桥梁。

1. **接口映射**：开发 Sim2Real 接口，将 Isaac Lab 输出的关节位置/速度/力矩指令 转换为 Unitree SDK2 协议。
2. **安全限制**：增加安全层（限幅、功率保护），防止实机损坏。
3. **通信测试**：通过 ROS2 或 SDK 直接控制实机进行微动测试。

### TASK 07：实物机器人测试与域差距校准

**目标**：完成实物机器人部署及动作优化。

1. **实机部署**：将训练好的 Policy 部署到机载计算机（如 Jetson Orin）。
2. **Reality Gap 分析**：观察实机与仿真的差异，反向调整仿真参数（系统辨识）。
3. **完整舞蹈展示**：实现音乐同步的完整舞蹈表演。
