本指南用于在 Windows 子系统 Linux (WSL) 上安装 Ubuntu 20.04，并配置宇树机器人（Unitree）MuJoCo 仿真环境。

## 一、安装 WSL + Ubuntu 20.04
### 1. 以管理员身份打开 PowerShell
右键点击"开始"菜单 → 选择"Windows PowerShell (管理员)"

### 2. 安装 Ubuntu 20.04
`wsl --install -d Ubuntu-20.04`
安装完成后会自动打开 Ubuntu 终端，按提示操作：
1.Create a default Unix user account: <输入用户名>
2.Enter new UNIX password: <输入密码（不显示）>
3.Retype new UNIX password: <再次输入密码确认>
看到 `Installation successful!` 即表示安装完成。

### 3. 更新系统
```
# 更新软件包列表
sudo apt update

# 升级所有已安装的软件包
sudo apt upgrade -y

# 清理不必要的依赖包
sudo apt autoremove -y
```
### 4. 安装开发必备工具
`sudo apt install -y build-essential git curl wget vim net-tools gnupg`

## 二、搭建仿真平台
### 1. 安装依赖库
`sudo apt install -y libyaml-cpp-dev libspdlog-dev libboost-all-dev libglfw3-dev`

### 2. 安装 CMake
`sudo apt install -y cmake`

### 3. 安装 unitree_sdk2
```
# 克隆仓库
git clone https://github.com/unitreerobotics/unitree_sdk2.git

# 进入目录并创建 build 文件夹
cd unitree_sdk2/
mkdir build && cd build

# 配置 CMake（推荐安装到 /opt/unitree_robotics）
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/unitree_robotics

# 编译并安装
sudo make install
```
### 4. 安装 MuJoCo
#### （1）下载
- 访问发布页：[https://github.com/google-deepmind/mujoco/releases](https://github.com/google-deepmind/mujoco/releases)
- 下载对应版本的 Linux 压缩包（如 `mujoco-3.3.6-linux-x86_64.tar.gz`）
- 将文件放入 Ubuntu 的 `/home/<你的用户名>/` 目录下

#### （2）解压并配置
```
# 创建 MuJoCo 隐藏目录
mkdir -p ~/.mujoco

# 解压到指定目录（请替换为实际文件名）
tar -zxvf ~/mujoco-3.3.6-linux-x86_64.tar.gz -C ~/.mujoco

# 进入目录确认结构
cd ~/.mujoco

ls  # 执行完应看到 mujoco-3.3.6 文件夹
```
### 5. 创建符号链接
```
# 进入 unitree_mujoco 的 simulate 目录
cd ~/unitree_mujoco/simulate/

# 创建符号链接（版本号需与实际安装一致）
ln -s ~/.mujoco/mujoco-3.3.6 mujoco
```
⚠️ 注意：如果安装的是 3.3.7 或其他版本，请相应调整链接目标路径。

### 6. 编译 unitree_mujoco
```
# 进入 simulate 目录并创建 build 文件夹
cd ~/unitree_mujoco/simulate
mkdir build && cd build

# 配置 CMake
cmake ..

# 编译（使用 4 线程加速）
make -j4
```
#### 🔧 编译失败？尝试以下修复：
```
# 1. 更新并安装缺失依赖
sudo apt update
sudo apt install -y libfmt-dev libunwind-dev

# 2. 清理并重新编译
make clean
make -j4
```
#### 编译成功后运行仿真
`./unitree_mujoco -r go2 -s scene_terrain.xml`

## 三、常见问题排查

|       问题       |     可能原因     |                    解决方案                     |
| :------------: | :----------: | :-----------------------------------------: |
| `make` 报错缺少头文件 |    依赖库未安装    | `sudo apt install libfmt-dev libunwind-dev` |
|     符号链接失效     | MuJoCo 版本不匹配 |     检查 `~/.mujoco/` 下实际文件夹名，重新 `ln -s`      |



