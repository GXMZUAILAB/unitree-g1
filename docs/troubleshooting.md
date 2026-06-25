# 常见问题速查

> 训练中遇到的常见报错和解决方法。可与教程 [3.7_troubleshooting.md](../3_g1_project/3.7_troubleshooting.md) 互补查阅。

---

## 训练崩溃

### `RuntimeError: normal expects all elements of std >= 0.0`

**原因**：策略网络权重被 NaN 污染，输出分布的标准差 ≤ 0。

**触发链**：action_rate 奖励爆炸 → value loss NaN → 梯度 NaN → 权重 NaN。

**排查步骤**：
1. 看上一条 iteration 的 `Mean value loss` 是否已经是 NaN
2. 查看 `Episode_Reward/action_rate` 是否异常大（正常应是 -0.1 ~ -0.5）
3. 如果有 TensorBoard，看 value loss 曲线从哪一步开始断崖

**修复**：
- 降低 `action_rate_l2` 权重（`-0.05` → `-0.01`）
- 降低其他强惩罚权重（见 [reward-design.md](reward-design.md)）
- 增大 `entropy_coef` 增加探索
- 从最近的 checkpoint resume 训练

### `Mean surrogate loss: 0.0000`

**原因**：PPO clip 太紧，策略几乎不更新。长期下去训练停滞。

**排查**：查看 `Mean action std`（正常应 >0.1）、`entropy_loss`（正常应 >1.0）

---

## Playback 问题

### 机器人一动不动

可能原因：
1. **模型没学会**：reward 惩罚太重，策略学到"不动最安全"
2. **Play 速度指令范围不同**：`RobotPlayEnvCfg` 使用 `limit_ranges`（-0.5~1.0），远超训练用的 `ranges`（-0.1~0.1）

**临时修**：注释掉 `velocity_env_cfg.py:481` 行，让 play 也走训练范围测试。

### 机器人摔倒不自己站起来

**原因**：G1 velocity tracking 任务没有"站起来"重置策略。摔倒触发 `bad_orientation` 终止，env 重置为站姿。如果模型本身不会走路，它永远在"摔倒→重置→站住→再摔倒"的循环里。

---

## 配置问题

### 改了配置文件参数但不生效

**原因**：参数覆盖优先级：CLI > env var > start.sh 默认值 > 配置文件。

- 如果 `TRAIN_NUM_ENVS` 环境变量被设置 → 覆盖配置文件
- v2.0 的 start.sh 只在**显式设置**环境变量时才传 CLI 参数

**检查**：
```bash
echo $TRAIN_NUM_ENVS   # 空 = 用配置文件，有值 = 覆盖
```

详见 [architecture-notes.md](architecture-notes.md)。

### Play 模式用不了

v2.0 的 play 支持交互式选择：
```bash
bash scripts/start.sh play        # 列出所有 run → 选 → 列所有 checkpoint → 选
bash scripts/start.sh play run名 checkpoint名   # 直接指定
PLAY_NUM_ENVS=4 bash scripts/start.sh play    # 控制环境数
```

---

## GPU 问题

### GPU 利用率低（~50%）

**大概率**：`TRAIN_NUM_ENVS` 设太小了（默认 4）。试试 4096。

### 显存不足 (OOM)

降低 `TRAIN_NUM_ENVS`，或查看 [hardware-profile.md](hardware-profile.md) 的推荐配置。

### 系统内存不足 + swap

降到 4096 envs。14GB RAM 的机器跑 8192 会吃 swap。

---

## Docker 问题

### `docker pull` 超时

检查代理：`ss -tlnp | grep 7897`。Clash Verge 必须运行。

### 3D 视口黑屏

检查是否用了 `--user 0:0`（start.sh v2.0 已配置），以及 GPU 驱动是否 580.x 版本。

### 日志文件是 root 权限删不掉

Docker 用 `--user 0:0` 运行，所有产物都是 root 的：
```bash
sudo rm -rf ~/projects/g1-rl/logs/rsl_rl/unitree_g1_29dof_velocity/<run_dir>
```
