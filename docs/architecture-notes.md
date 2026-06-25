# 架构笔记

> CLI 参数流、start.sh 设计决策、参数覆盖链分析。

---

## 参数传递链

训练模式的完整参数流：

```
用户设置 env var (可选)
  │
  ▼
start.sh build_train_args()
  │  只有 env var 被设置时才生成 CLI flag
  │  TRAIN_NUM_ENVS=4096 → 生成 --num_envs 4096
  │  TRAIN_NUM_ENVS 未设置 → 不生成
  │
  ▼
train.py argparse
  │  --num_envs: default=None
  │  --max_iterations: default=None
  │
  ▼
train.py main()
  │  if args_cli.num_envs is not None:        ← CLI 有值 → 覆盖
  │      env_cfg.scene.num_envs = ...          ← CLI 是 None → 保配置
  │
  ▼
velocity_env_cfg.py RobotEnvCfg
  │  scene.num_envs = 4096*4 (=16384)
  │  这是 SOURCE OF TRUTH（当没有 CLI override 时）
```

**设计原则**（v2.0）：
- 配置文件是默认值的唯一来源
- 环境变量是可选的覆盖机制
- start.sh 只是通道，不参与默认值设定

---

## start.sh v1.0 → v2.0 变更

### v1.0 的问题

```bash
# v1.0 — 强制覆盖
TRAIN_NUM_ENVS="${TRAIN_NUM_ENVS:-4}"     # 永远默认 4
--num_envs ${TRAIN_NUM_ENVS}              # 永远传给 train.py
```

配置文件 `num_envs=16384` 永远不生效。

### v2.0 的修复

```bash
# v2.0 — 仅在用户设置时覆盖
build_train_args() {
    [[ -n "${TRAIN_NUM_ENVS:-}" ]] && args="${args} --num_envs ${TRAIN_NUM_ENVS}"
    [[ -n "${TRAIN_MAX_ITER:-}" ]] && args="${args} --max_iterations ${TRAIN_MAX_ITER}"
}
```

未设置 → argparse 收到 `None` → 走配置文件值。

### v2.0 新增功能

- **resume**: 交互式选择 run + checkpoint 恢复训练
- **play**: 自动扫描并列出可用模型，编号选择
- **PLAY_NUM_ENVS**: play 模式独立控制环境数
- **菜单**: 显示当前 envs/iter 来自哪里

---

## train.py 兼容性修复

有 4 个针对 `rsl-rl-lib 5.0.1` 的兼容性修复（已应用）：

| # | 文件 | 修复内容 |
|---|------|---------|
| 1 | `cli_args.py:60-63` | `parse_rsl_rl_cfg()` 调用 `handle_deprecated_rsl_rl_cfg()` |
| 2 | `play.py:132-150` | `PPO.policy` → `PPO.actor`，导出用 `runner.export_*` |
| 3 | `IsaacLab/utils.py:309` | `hasattr` guard for `stochastic` |
| 4 | `train.py:130-140` | 删除重复的 `handle_deprecated_rsl_rl_cfg` 调用 |

**重要**：如果重新克隆 `sim/` 下的仓库，需要重新应用修复。

---

## 已修复的代码问题

| 问题 | 文件 | 状态 |
|------|------|:----:|
| 重复 `handle_deprecated_rsl_rl_cfg` 调用 | train.py:133,136 | ✅ |
| `--task` default=None 无防护 | train.py:40 | 🟡 被 start.sh 兜底 |
| play 模式 `--num_envs` 硬编码 | start.sh:314 | ✅ 加 PLAY_NUM_ENVS |
| CLI 参数覆盖配置文件 | start.sh:8,109 | ✅ v2.0 修复 |

---

## 文档链接

- 当前目录结构 + 维护状态：见本文件
- 训练配置分析：见 [reward-design.md](reward-design.md)
- 崩溃分析：见 [failure-analysis.md](failure-analysis.md)
