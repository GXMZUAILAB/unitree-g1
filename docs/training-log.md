# 训练记录

> 每次训练的配置参数、硬件表现、结果。按时间倒序排列。

---

## 2026-06-24 — 第 8 次：4096 envs，崩溃于 18140 步

**命令**：
```bash
TRAIN_NUM_ENVS=4096 TRAIN_MAX_ITER=20000 bash scripts/start.sh train
```

**配置**：
- Num envs: 4096
- Max iterations: 20000
- Steps per second: 37300
- decimation=4, dt=0.005

**结果**：❌ 在 18140/20000 崩溃
```
RuntimeError: normal expects all elements of std >= 0.0
Mean value loss: nan
action_rate reward: -5.49×10²⁵
```

**崩溃前关键指标**：
| 指标 | 值 |
|------|----|
| track_lin_vel_xy | 0.53 |
| bad_orientation | 58.8% |
| time_out | 40.9% |
| terrain_levels | 1.33 |
| entropy_loss | 23.74 |
| surrogate_loss | 0.0 |

**分析**：reward 惩罚过重（惩罚/奖励比 8:1），策略萎缩为"不动最安全"。详见 [failure-analysis.md](failure-analysis.md)。

---

## 2026-06-24 — 第 7 次：8192 envs，内存告警

**命令**：
```bash
TRAIN_NUM_ENVS=8192 TRAIN_MAX_ITER=20000 bash scripts/start.sh train
```

**硬件表现**：
| 指标 | 值 |
|------|----|
| GPU 利用率 | 81% |
| 显存 | 9.6 GiB / 16 GiB (60%) |
| GPU 功耗 | 103 W / 150 W |
| GPU 温度 | 84°C |
| 系统内存 | 12.6 / 14.4 G (87%) |
| Swap | 3.25 / 4.0 G 🔴 |

**结论**：8192 envs 对 RTX 3080 的提升递减（77%→81%），但系统内存推到 87% + swap。**退回 4096**。

---

## 2026-06-24 — GPU 利用率实验

测试了 3 种 envs 配置对 GPU 利用率的影响：

| envs | GPU利用率 | 显存 | 功耗 | 系统内存 | 评价 |
|------|----------|------|------|---------|------|
| 4    | 50%      | 3.4G | 51W  | —       | 太少了，GPU 饿死 |
| 4096 | 77%      | 6.7G | 98W  | —       | ✅ 当前硬件甜点 |
| 8192 | 81%      | 9.6G | 103W | 12.6/14G 🔴 | 内存碰红线 |

**结论**：4096 是 RTX 3080 + 14G 系统内存的最佳配置。PPO on-policy 训练天然有"采集→更新"交替周期，GPU 在采集阶段必然空闲，**不需要追求 99% 利用率**。

---

## 2026-06-23 — 早期尝试（数据已清理）

多次快速测试（envs=4~32，只跑了 0~499 步），属于探索性试跑，无有价值的训练结果。
