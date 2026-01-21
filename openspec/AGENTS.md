# OpenSpec 指南 (OpenSpec Instructions)

AI 编程助手使用 OpenSpec 进行规格驱动开发 (Spec-driven Development) 的指南。

## TL;DR 快速核查清单 (Quick Checklist)

- **搜索现有工作**: `openspec spec list --long`, `openspec list`（仅在进行全文本搜索时使用 `rg`）
- **确定范围**: 新功能 (New Capability) vs 修改现有功能 (Modify Capability)
- **选择唯一的 `change-id`**: kebab-case，动词开头（如 `add-`, `update-`, `remove-`, `refactor-`）
- **脚手架 (Scaffold)**: `proposal.md`, `tasks.md`, `design.md`（仅在需要时），以及每个受影响功能的 Delta Specs
- **编写 Deltas**: 使用 `## ADDED|MODIFIED|REMOVED|RENAMED Requirements`；每个需求至少包含一个 `#### Scenario:`
- **验证 (Validate)**: `openspec validate [change-id] --strict --no-interactive` 并修复问题
- **请求批准**: 在提案 (Proposal) 获得批准前，不要开始实施 (Implementation)

## 三阶段工作流 (Three-Stage Workflow)

### 第 1 阶段：创建更改 (Creating Changes)
在需要执行以下操作时创建提案：
- 添加功能或属性
- 进行破坏性更改 (Breaking Changes)（API、Schema）
- 更改架构或模式 (Patterns)
- 性能优化（涉及行为更改）
- 更新安全模式

**触发词（示例）**:
- "帮我创建一个更改提案 (Change Proposal)"
- "帮我规划一个更改"
- "帮我创建一个提案"
- "我想创建一个 Spec 提案"
- "我想创建一个 Spec"

**模糊匹配指导**:
- 包含以下之一：`proposal`, `change`, `spec`
- 搭配以下之一：`create`, `plan`, `make`, `start`, `help`

**无需提案的情况**:
- 错误修复 (Bug Fixes)（恢复预期行为）
- 拼写错误、格式化、注释
- 依赖项更新（非破坏性）
- 配置更改
- 针对现有行为的测试

**工作流**
1. 查阅 `openspec/project.md`、`openspec list` 和 `openspec list --specs` 以了解当前上下文。
2. 选择一个唯一的动词开头的 `change-id`，并在 `openspec/changes/<id>/` 下搭建 `proposal.md`、`tasks.md`、可选的 `design.md` 以及 Spec Deltas 的脚手架。
3. 使用 `## ADDED|MODIFIED|REMOVED Requirements` 起草 Spec Deltas，每个需求至少包含一个 `#### Scenario:`。
4. 运行 `openspec validate <id> --strict --no-interactive`，并在分享提案前解决所有问题。

### 第 2 阶段：实施更改 (Implementing Changes)
将以下步骤作为 TODO 跟踪并逐一完成。
1. **阅读 proposal.md** - 了解正在构建的内容
2. **阅读 design.md**（如果存在） - 审查技术决策
3. **阅读 tasks.md** - 获取实施核查清单
4. **按顺序实施任务** - 依次完成
5. **确认完成** - 在更新状态前确保 `tasks.md` 中的每个项目都已完成
6. **更新清单** - 所有工作完成后，将每个任务设置为 `- [x]`，以反映实际情况
7. **批准门禁** - 在提案通过评审并获得批准前，不要开始实施

### 第 3 阶段：归档更改 (Archiving Changes)
部署完成后，创建单独的 PR 以：
- 移动 `changes/[name]/` → `changes/archive/YYYY-MM-DD-[name]/`
- 如果功能发生变化，更新 `specs/`
- 对于仅涉及工具链的更改，使用 `openspec archive <change-id> --skip-specs --yes`（始终显式传递 Change ID）
- 运行 `openspec validate --strict --no-interactive` 以确认归档的更改通过检查

## 在执行任何任务之前 (Before Any Task)

**上下文核查清单 (Context Checklist):**
- [ ] 阅读 `specs/[capability]/spec.md` 中的相关 Specs
- [ ] 检查 `changes/` 中的待定更改是否存在冲突
- [ ] 阅读 `openspec/project.md` 了解约定 (Conventions)
- [ ] 运行 `openspec list` 查看活动更改
- [ ] 运行 `openspec list --specs` 查看现有功能 (Capabilities)

**在创建 Specs 之前:**
- 始终检查功能是否已存在
- 优先选择修改现有 Specs，而不是创建重复项
- 使用 `openspec show [spec]` 审查当前状态
- 如果请求模糊不清，在搭建脚手架前提出 1–2 个澄清问题的建议

### 搜索指导 (Search Guidance)
- 列举 Specs: `openspec spec list --long`（脚本使用 `--json`）
- 列举更改: `openspec list`（或 `openspec change list --json` - 已弃用但可用）
- 显示详细信息:
  - Spec: `openspec show <spec-id> --type spec`（使用 `--json` 进行过滤）
  - Change: `openspec show <change-id> --json --deltas-only`
- 全文本搜索（使用 ripgrep）: `rg -n "Requirement:|Scenario:" openspec/specs`

## 快速上手 (Quick Start)

### 命令行工具 (CLI Commands)

```bash
# 基本命令
openspec list                  # 列出活动更改
openspec list --specs          # 列出规格 (Specifications)
openspec show [item]           # 显示更改或规格
openspec validate [item]       # 验证更改或规格
openspec archive <change-id> [--yes|-y]   # 部署后归档 (添加 --yes 用于非交互式运行)

# 项目管理
openspec init [path]           # 初始化 OpenSpec
openspec update [path]         # 更新指令文件

# 交互模式
openspec show                  # 提示选择
openspec validate              # 批量验证模式

# 调试
openspec show [change] --json --deltas-only
openspec validate [change] --strict --no-interactive
```

### 命令标志 (Command Flags)

- `--json` - 机器可读的输出
- `--type change|spec` - 消除项的歧义
- `--strict` - 全面的验证
- `--no-interactive` - 禁用提示
- `--skip-specs` - 归档时不更新 Spec
- `--yes`/`-y` - 跳过确认提示（非交互式归档）

## 目录结构 (Directory Structure)

```
openspec/
├── project.md              # 项目约定
├── specs/                  # 当前事实 - 已构建的内容
│   └── [capability]/       # 单一聚焦的功能
│       ├── spec.md         # 需求和场景
│       └── design.md       # 技术模式
├── changes/                # 提案 - 应该更改的内容
│   ├── [change-name]/
│   │   ├── proposal.md     # 为什么、什么、影响
│   │   ├── tasks.md        # 实施核查清单
│   │   ├── design.md       # 技术决策（可选；见标准）
│   │   └── specs/          # Delta 更改
│   │       └── [capability]/
│   │           └── spec.md # ADDED/MODIFIED/REMOVED
│   └── archive/            # 已完成的更改
```

## 创建更改提案 (Creating Change Proposals)

### 决策树 (Decision Tree)

```
新请求？
├─ 修复 Spec 行为的错误？ → 直接修复
├─ 拼写/格式/注释？ → 直接修复  
├─ 新功能/新能力？ → 创建提案
├─ 破坏性更改？ → 创建提案
├─ 架构更改？ → 创建提案
└─ 不明确？ → 创建提案（更安全）
```

### 提案结构 (Proposal Structure)

1. **创建目录:** `changes/[change-id]/`（kebab-case，动词开头，唯一）

2. **编写 proposal.md:**
```markdown
# Change: [更改的简短描述]

## Why
[关于问题/机会的 1-2 句话]

## What Changes
- [更改的列表点]
- [用 **BREAKING** 标记破坏性更改]

## Impact
- 受影响的 Specs: [功能列表]
- 受影响的代码: [关键文件/系统]
```

3. **创建 Spec Deltas:** `specs/[capability]/spec.md`
```markdown
## ADDED Requirements
### Requirement: 新功能
系统 SHALL (应当) 提供...

#### Scenario: 成功案例
- **WHEN** 用户执行操作
- **THEN** 预期结果

## MODIFIED Requirements
### Requirement: 现有功能
[完整修改后的需求]

## REMOVED Requirements
### Requirement: 旧功能
**Reason (原因)**: [为什么删除]
**Migration (迁移)**: [如何处理]
```
如果受影响的有多个功能，请在 `changes/[change-id]/specs/<capability>/spec.md` 下创建多个 Delta 文件——每个功能一个。

4. **创建 tasks.md:**
```markdown
## 1. Implementation
- [ ] 1.1 创建数据库 Schema
- [ ] 1.2 实施 API 端点
- [ ] 1.3 添加前端组件
- [ ] 1.4 编写测试
```

5. **必要时创建 design.md:**
仅在符合以下任一条件时创建 `design.md`；否则省略：
- 跨领域更改（多个服务/模块）或新的架构模式
- 新的外部依赖项或重大数据模型更改
- 安全性、性能或迁移复杂性
- 在编码前能从技术决策中受益的不确定性

最小化的 `design.md` 骨架：
```markdown
## Context (上下文)
[背景、约束、利害关系人]

## Goals / Non-Goals (目标 / 非目标)
- Goals: [...]
- Non-Goals: [...]

## Decisions (决策)
- Decision: [内容和原因]
- Alternatives considered (考虑过的替代方案): [选项 + 理由]

## Risks / Trade-offs (风险 / 权衡)
- [风险] → 缓解措施

## Migration Plan (迁移计划)
[步骤、回滚]

## Open Questions (待解决问题)
- [...]
```

## Spec 文件格式

### 关键：场景格式化 (Scenario Formatting)

**正确**（使用 #### 标题）：
```markdown
#### Scenario: 用户登录成功
- **WHEN** 提供了有效的凭据
- **THEN** 返回 JWT Token
```

**错误**（不要使用项目符号或加粗）：
```markdown
- **Scenario: 用户登录**  ❌
**Scenario**: 用户登录     ❌
### Scenario: 用户登录      ❌
```

每个需求必须至少有一个场景。

### 需求措辞 (Requirement Wording)
- 使用 SHALL/MUST 来表达规范性需求（除非有意表达非规范性，否则避免使用 should/may）

### Delta 操作 (Delta Operations)

- `## ADDED Requirements` - 新功能
- `## MODIFIED Requirements` - 已更改的行为
- `## REMOVED Requirements` - 已弃用的特性
- `## RENAMED Requirements` - 名称更改

标题匹配使用 `trim(header)` - 忽略空格。

#### 何时使用 ADDED vs MODIFIED
- ADDED: 引入一个新的功能或子功能，可以作为一个独立的需求存在。当更改是正交的（例如，添加 "斜杠命令配置"）而不是改变现有需求的语义时，优先使用 ADDED。
- MODIFIED: 更改现有需求的行为、范围或验收标准。始终粘贴**完整的、更新后的**需求内容（标题 + 所有场景）。归档器将用你提供的内容替换整个需求；部分 Delta 将导致之前的细节丢失。
- RENAMED: 仅在名称更改时使用。如果你同时更改了行为，请使用 RENAMED（名称）加上 MODIFIED（内容）并引用新名称。

常见陷阱：使用 MODIFIED 添加一个新关注点，却不包含之前的文本。这会导致在归档时丢失细节。如果你不是显式地更改现有需求，请改为在 ADDED 下添加一个新需求。

正确编写 MODIFIED 需求：
1) 在 `openspec/specs/<capability>/spec.md` 中找到现有的需求。
2) 复制整个需求块（从 `### Requirement: ...` 到其场景）。
3) 将其粘贴到 `## MODIFIED Requirements` 下，并进行编辑以反映新行为。
4) 确保标题文本完全匹配（忽略空格），并至少保留一个 `#### Scenario:`。

RENAMED 示例：
```markdown
## RENAMED Requirements
- FROM: `### Requirement: Login`
- TO: `### Requirement: User Authentication`
```

## 故障排除 (Troubleshooting)

### 常见错误
**"Change must have at least one delta" (更改必须至少包含一个 Delta)**
- 检查 `changes/[name]/specs/` 是否存在且包含 .md 文件
- 确认文件具有操作前缀 (## ADDED Requirements)

**"Requirement must have at least one scenario" (需求必须至少包含一个场景)**
- 检查场景是否使用 `#### Scenario:` 格式（4 个 # 号）
- 不要对场景标题使用项目符号或加粗

**场景解析静默失败**
- 必需的精确格式：`#### Scenario: 名称`
- 调试命令：`openspec show [change] --json --deltas-only`

### 验证提示
```bash
# 始终使用严格模式进行全面检查
openspec validate [change] --strict --no-interactive

# 调试 Delta 解析
openspec show [change] --json | jq '.deltas'

# 检查特定需求
openspec show [spec] --json -r 1
```

## 快乐路径脚本 (Happy Path Script)

```bash
# 1) 探索当前状态
openspec spec list --long
openspec list
# 可选的全文本搜索:
# rg -n "Requirement:|Scenario:" openspec/specs
# rg -n "^#|Requirement:" openspec/changes

# 2) 选择 Change ID 并搭建脚手架
CHANGE=add-two-factor-auth
mkdir -p openspec/changes/$CHANGE/{specs/auth}
printf "## Why\n...\n\n## What Changes\n- ...\n\n## Impact\n- ...\n" > openspec/changes/$CHANGE/proposal.md
printf "## 1. Implementation\n- [ ] 1.1 ...\n" > openspec/changes/$CHANGE/tasks.md

# 3) 添加 Deltas (示例)
cat > openspec/changes/$CHANGE/specs/auth/spec.md << 'EOF'
## ADDED Requirements
### Requirement: Two-Factor Authentication
用户在登录期间 MUST (必须) 提供第二个因素。

#### Scenario: 需要 OTP
- **WHEN** 提供了有效的凭据
- **THEN** 需要进行 OTP 挑战
EOF

# 4) 验证
openspec validate $CHANGE --strict --no-interactive
```

## 多功能示例 (Multi-Capability Example)

```
openspec/changes/add-2fa-notify/
├── proposal.md
├── tasks.md
└── specs/
    ├── auth/
    │   └── spec.md   # ADDED: Two-Factor Authentication
    └── notifications/
        └── spec.md   # ADDED: OTP email notification
```

auth/spec.md
```markdown
## ADDED Requirements
### Requirement: Two-Factor Authentication
...
```

notifications/spec.md
```markdown
## ADDED Requirements
### Requirement: OTP Email Notification
...
```

## 最佳实践 (Best Practices)

### 简单优先 (Simplicity First)
- 默认每次新代码少于 100 行
- 在证明不足之前，采用单文件实施
- 避免在没有明确理由的情况下使用框架
- 选择无聊、经过验证的模式

### 复杂性触发因素 (Complexity Triggers)
仅在以下情况添加复杂性：
- 性能数据显示当前解决方案太慢
- 具体的可扩展性需求（>1000 用户，>100MB 数据）
- 多个经过验证的用例需要进行抽象

### 清晰的引用 (Clear References)
- 使用 `file.ts:42` 格式表示代码位置
- 引用 Specs 为 `specs/auth/spec.md`
- 链接相关的更改和 PR

### 功能命名建议 (Capability Naming)
- 使用 动词-名词: `user-auth`, `payment-capture`
- 每个功能只有单一目的
- 10 分钟可理解性原则
- 如果描述中需要使用 "AND (且)"，请考虑拆分

### Change ID 命名
- 使用 kebab-case，简短且具有描述性: `add-two-factor-auth`
- 优先选择动词开头的前缀: `add-`, `update-`, `remove-`, `refactor-`
- 确保唯一性；如果已被占用，请附加 `-2`, `-3` 等。

## 工具选择指南 (Tool Selection Guide)

| 任务           | 工具 | 理由           |
| -------------- | ---- | -------------- |
| 按模式查找文件 | Glob | 快速模式匹配   |
| 搜索代码内容   | Grep | 优化的正则搜索 |
| 读取特定文件   | Read | 直接文件访问   |
| 探索未知领域   | Task | 多步骤调查     |

## 错误恢复 (Error Recovery)

### 更改冲突 (Change Conflicts)
1. 运行 `openspec list` 查看活动更改
2. 检查重叠的 Specs
3. 与更改所有者协调
4. 考虑合并提案

### 验证失败 (Validation Failures)
1. 使用 `--strict` 标志运行
2. 检查 JSON 输出以获取详细信息
3. 核实 Spec 文件格式
4. 确保场景格式正确

### 缺少上下文 (Missing Context)
1. 首先阅读 `project.md`
2. 检查相关 Specs
3. 查看最近的归档项目
4. 请求澄清

## 快速参考 (Quick Reference)

### 阶段指标 (Stage Indicators)
- `changes/` - 已提议，尚未构建
- `specs/` - 已构建并部署
- `archive/` - 已完成的更改

### 文件用途
- `proposal.md` - 为什么以及是什么
- `tasks.md` - 实施步骤
- `design.md` - 技术决策
- `spec.md` - 需求和行为

### CLI 必备命令
```bash
openspec list              # 正在进行什么？
openspec show [item]       # 查看详细信息
openspec validate --strict --no-interactive  # 是否正确？
openspec archive <change-id> [--yes|-y]  # 标记为已完成 (添加 --yes 用于自动化)
```

请记住：Specs 是事实。Changes 是提案。保持它们同步。
