# 成果展示

> 训练过程中的阶段性成果。每张 GIF/截图文件名就是描述，点进来直接看。

## 📁 文件命名约定

把 GIF/截图放到 `gifs/` 目录，文件名用描述性短语（英文），例如：
- `first_successful_walk.gif` — 第一次成功走起来
- `episode_5000_standup.gif` — 5000 步学会了站起来
- `training_crash_nan.gif` — 训练崩溃前的异常抖动
- `ppo_value_loss_curve.png` — Value Loss 断崖图

文件名即说明，无需额外 README。

## 🗂️ 展示清单

<!-- 当你有 GIF 后，取消下面对应行的注释并添加文件名 -->

### 🏃 阶段性里程碑
<!-- | 训练步数 | 描述 | 文件 | 日期 |
|---------|------|------|------|
| 500 | 会站起来了 | `gifs/500_stand_up.gif` | 2026-06-25 |
| 2000 | 第一次迈步 | `gifs/2000_first_step.gif` | 2026-06-25 |
| 10000 | 稳定行走 | `gifs/10000_stable_walk.gif` | 2026-06-26 | -->

### 🐛 失败案例分析
<!-- | 问题 | 描述 | 文件 |
|------|------|------|
| NaN 崩溃 | 18140步 action_rate 爆炸 | `gifs/nan_crash.gif` |
| 僵尸步态 | 惩罚过重导致不动 | `gifs/zombie_stand.gif` | -->

### 📊 训练曲线
<!-- | 指标 | 描述 | 文件 |
|------|------|------|
| GPU利用率对比 | 4envs vs 4096envs | `gifs/gpu_utilization.png` |
| reward曲线 | 训练过程中的reward变化 | `gifs/reward_curve.png` | -->

---

> 把 GIF 扔到 `gifs/` 文件夹里，然后更新上面的表格即可。详细的问题分析见 [docs/](../docs/)。
