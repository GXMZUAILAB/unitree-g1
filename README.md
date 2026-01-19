# 🤖 Unitree G1 强化学习舞蹈项目

> **"VibeCoding" 开发范式**：本项目采用 AI 原生协作模式。AI 不仅是助手，更是核心开发者。我们通过结构化的提示词（Prompts）和高质量的文档（Docs）作为 AI 的“数字神经”，实现具身智能任务的高效迭代。

---

## 📂 项目架构

为了让 AI 和人类协作更加丝滑，本项目采用了严谨的结构化布局：

- **🧠 prompts/**: **核心大脑**。存放所有引导 AI 的“秘籍”。
    - `code_expert.txt`: 初始化代码专家人格。
    - `code_reviewer.txt`: 严格的代码回溯与评审脚本。
    - `coding/`: 针对特定复杂逻辑的迭代提示词。
- **📚 docs/**: **知识底座**。AI 的上下文来源。
    - `T1_环境与工具链搭建.md`: 必须严格遵守的“真理”文档（适配 Isaac Lab）。
    - `main_guide.md`: 任务分解与核心逻辑架构。
    - `research_report.md`: 项目立项与技术趋势分析。
- **⚙️ configs/**: 基于 Hydra 的参数管理，解耦算法与环境配置。
- **🏗️ unitree_rl/**: 核心代码。包含 G1 的环境封装、奖励函数（Reward Shaper）与观测站。
- **🧪 scripts/**: 自动化训练流程（Train）与 仿真回放（Play）。

---

## 🛠 开发流程 (The Vibe Process)

协作人员在开始任何任务前，**请务必遵循以下“VibeCoding”三部曲**：

1. **加载灵魂 (Load Soul)**：
   打开对话前，先将 `prompts/code_expert.txt` 的内容输入给 AI。这会强制 AI 进入“宇树 G1 & Isaac Lab 专家”模式。
2. **注入真理 (Inject Truth)**：
   将相关的 `docs/` 内容（如 `T1` 或 `main_guide`）通过 @ 引用或直接粘贴，确保 AI 所有的生成都基于当前的技术选型。
3. **循环迭代 (Loop & Refine)**：
   遇到报错？调用 `prompts/code_reviewer.txt`。代码逻辑太乱？查看 `prompts/coding/` 中的重构模板。

```javascript
graph LR
    User[协作人员] --> Prompt[prompts/ 引导]
    Prompt --> AI[AI 专家助理]
    AI --> Code[生成 Isaac Lab 代码]
    Code --> Sim[Isaac Sim 仿真验证]
    Sim -- 报错 --> Review[code_reviewer.txt]
    Review --> AI
```

---

## 🚀 快速启动

### 1. 环境准备

请务必先完成 **Task 01**：
[📖 查阅 T1: 环境与工具链搭建指南](docs/T1_环境与工具链搭建.md)

### 2. 训练与回放

```bash
# 启动 G1 舞蹈任务训练
python scripts/train.py task=G1_Dance

# 回放最优 Checkpoint
python scripts/play.py checkpoint=latest
```

---

## 🛰 项目进度 (Roadmap)

- \[/] **Phase 1: 环境底座** - Isaac Sim (Standalone) & Isaac Lab 适配完成。
- **Phase 2: 规范建立** - VibeCoding 开发流与提示词工程搭建。
- **Phase 3: 动作制备** - BVH 动作重定向与标准化 (进展中)。
- **Phase 4: 策略迭代** - PPO/AMP 算法训练。
- **Phase 5: 实机部署** - Unitree SDK2 Sim2Real 验证。

---

> \[!TIP]
> **记住**：在 VibeCoding 模式下，文档的准确性、Prompt 的深度决定了 AI 生成代码的上限。请像维护代码一样维护你的 `prompts/` 目录。
