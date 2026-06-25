# 训练失败深度分析

> 2026-06-24 训练到 18140/20000 步 NaN 崩溃的完整分析。

---

## 崩溃现场

```
Learning iteration 18140/20000

Steps per second:           37300
Mean value loss:            nan
Mean surrogate loss:        0.0000
Mean reward:                -2.37×10²⁷
Episode_Reward/action_rate: -5.49×10²⁵
Mean action std:            0.56

→ RuntimeError: normal expects all elements of std >= 0.0
```

## 崩溃链路

```
策略网络某隐藏层权重变大
  → 输出动作值巨大（10¹³ 量级跳变）
  → action_rate_l2 = ||a_t - a_{t-1}||² 惩罚爆炸（×0.05 权重 → 10²⁵）
  → 一个 NaN reward 污染整个 batch 的 returns
  → Value loss 计算被 NaN 污染
  → PPO gradient 被 NaN 污染
  → 网络权重变成 NaN
  → 下一轮 forward: σ = NaN × W → std ≤ 0 → 崩溃
```

### 为什么 value loss 先变 NaN？

1. `action_rate=-5×10²⁵` 是一个超出 FP32 正常量级的惩罚
2. PPO 的 `value_loss_coef=1.0`，这个巨型值直接灌进 loss
3. GAE advantage 计算中某一步 return 是 NaN
4. 反向传播，权重被 NaN 污染

---

## 根本原因：reward 惩罚扼杀了探索

训练全程的 18 个 reward term 中：
- **13 个惩罚**（负权重），总绝对值 24.4
- **5 个奖励**（正权重），总绝对值 3.15
- **惩罚是奖励的 8 倍**

三个主要杀手：
- `joint_deviation_waists=-1.0` + `joint_deviation_legs=-1.0` → 腰/腿稍微偏一点大扣分
- `base_height=-10.0` → 站姿误差极低容忍
- `action_rate=-0.05` → 29 维动作差平方和，爆炸风险

策略学到的："保持默认姿态别乱动" = 最小化惩罚的最优解。

这就解释了 **play 时机器人一动不动**。

---

## 恶性循环：terrain curriculum 死锁

`terrain_levels_vel` 的逻辑（curriculums.py:27-56）：

```python
move_up   = distance > size[0] / 2        # 走 >0.5m → 难度提升
move_down = distance < norm(cmd) × 20 × 0.5  # 走得不够 → 难度降低
```

实际训练中 `terrain_levels=1.33`（≥18000 步仍在地形最简单层级）：

```
惩罚太重 → 不敢动 → speed=0 → distance=0
→ move_down 触发 → terrain level 降到 0
→ 一直练平坦地形 → 没有挑战 → 不需要学走路
→ 训练无进展 → 策略缩在安全区
```

---

## PPO 参数辅助恶化

从 `rsl_rl_ppo_cfg.py`：

| 参数 | 当前值 | 问题 |
|------|:-----:|------|
| `entropy_coef` | 0.01 | 太低，策略过早失去探索 |
| `max_grad_norm` | 1.0 | 不够激进地限制梯度 |
| `clip_param` | 0.2 | 标准值，没问题 |
| `surrogate loss=0.0` | — | 暗示 clip 太紧，策略不更新 |

---

## 修复建议

| 优先级 | 改动 | 文件 | 当前 → 建议 |
|--------|------|------|:---------:|
| 🔴 | `action_rate` weight | velocity_env_cfg.py:309 | -0.05 → **-0.01** |
| 🔴 | `joint_deviation_waists` weight | velocity_env_cfg.py:329 | -1.0 → **-0.2** |
| 🔴 | `joint_deviation_legs` weight | velocity_env_cfg.py:342 | -1.0 → **-0.2** |
| 🟡 | `entropy_coef` | rsl_rl_ppo_cfg.py:30 | 0.01 → **0.02** |
| 🟡 | `base_height` weight | velocity_env_cfg.py:347 | -10 → **-1.0** |
| 🟡 | `desired_kl` | rsl_rl_ppo_cfg.py:37 | 0.01 → **0.008** |
| 🟢 | curriculum 确认 | velocity_env_cfg.py:404 | 确认 `terrain_levels` 正确注册 |

详见 [reward-design.md](reward-design.md) 的完整权重分析。
