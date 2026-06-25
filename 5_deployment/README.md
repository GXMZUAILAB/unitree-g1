# 🟣 真机部署

> 你已经训练出了一个能走路的 AI。现在，把它放进真正的机器人身体里。

---

## 前提条件

在开始这一章之前，你应该：
- ✅ 跑过至少一次训练，知道自己训练出来的模型在 `logs/` 下的哪个目录
- ✅ 有一台能接触到的 G1 机器人（实验室里的，或者你自己的）
- ✅ 知道机器人的 IP 地址（不知道？[5.2](5.2_connect_to_robot.md) 会教你查）

---

## 📖 教程列表

| # | 教程 | 回答什么问题 |
|---|------|------------|
| [5.1](5.1_deploy_architecture.md) | 部署全景图 | 仿真到真机是怎么连起来的？ONNX、DDS、FSM 都是什么？ |
| [5.2](5.2_connect_to_robot.md) | 连接机器人 | SSH 是什么？怎么从你的电脑连到机器人？IP 在哪查？ |
| [5.3](5.3_model_export.md) | 导出 ONNX 模型 | 把 .pt 模型转成机器人能读的 .onnx 格式 |
| [5.4](5.4_build_on_robot.md) | 在机器人上编译 | 把 C++ 代码变成可运行的程序 |
| [5.5](5.5_run_on_robot.md) | 在机器人上运行 | 手柄怎么按？状态怎么切？怎么安全地停下来？ |
| [5.6](5.6_troubleshooting.md) | 排错速查 | 机器人不动？报错了？查这张表 |
| [5.7](5.7_how_it_works.md) | 源码深度解读 | 每一行 C++ 代码在干什么（给想深入的人看） |
| [5.8](5.8_mimic_controller.md) | 附加：动作模仿 | 让机器人跳舞 — Mimic 的原理和启用方法 |

---

## 🚀 走通全链路（一张图）

```
你的电脑                        G1 机器人
════════                        ════════

1. bash scripts/deploy.sh export
   从训练日志复制 ONNX 到 deploy/
                        │
2. bash scripts/deploy.sh push 192.168.1.100
   通过网络传到机器人 ──────────►  3. SSH 连上去
                                    bash install_onnxruntime.sh
                                    cd g1_29dof/build
                                    cmake .. && make -j

                                   4. ./g1_ctrl --network eth0
                                      L2+↑ → 站立 → R1+X → 走路！
```

---

## 本章要用到的命令

在你电脑上：
```bash
bash scripts/deploy.sh export            # 导出模型
bash scripts/deploy.sh push <机器人IP>    # 传代码到机器人
```

在机器人上（SSH 连过去之后）：
```bash
cd ~/g1-rl-deploy
bash install_onnxruntime.sh              # 装 ONNX Runtime（只需一次）
export ONNXRUNTIME_ROOT=~/g1-rl-deploy/thirdparty/onnxruntime-linux-x64-1.22.0
cd g1_29dof && mkdir -p build && cd build
cmake .. && make -j                       # 编译
./g1_ctrl --network eth0                  # 运行！
```
