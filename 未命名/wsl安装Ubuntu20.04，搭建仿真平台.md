# wsl安装Ubuntu20.04

## 1. **以管理员身份打开 PowerShell**
右键点击"开始"菜单 → 选择"Windows PowerShell (管理员)"
## 2.输入wsl --install -d Ubuntu-20.04
   安装完成后会自动打开 Ubuntu 窗口，提示：
  （请在此处输入你想要的用户名↑） **Create a default Unix user account:**
  （请在此处输入密码，一般不显示输入的内容）
  系统提示：**Enter new UNIX password:**
   （再次输入密码确认） **Retype new UNIX password:**
   看到**Installation successful!** 即安装完成
## 3. 更新系统
依次输入：
1.更新软件包
sudo apt update
2.升级所有软件包
sudo apt upgrade -y
3.清理不必要的软件包
sudo apt autoremove -y

注释：sudo`：以管理员权限运行
-     `apt`：Ubuntu 的软件包管理器
     `update`：更新命令
## 4.安装开发必备工具
sudo apt install -y build-essential git curl wget vim net-tools gnupg

# 搭建仿真平台

## 1.安装依赖库
sudo apt install libyaml-cpp-dev libspdlog-dev libboost-all-dev libglfw3-dev
进入目录
 
## 2.安装开发工具
sudo apt install cmake

## 3.安装 unitree_sdk2
- 克隆仓库：git clone https://github.com/unitreerobotics/unitree_sdk2.git
- 进入目录：cd unitree_sdk2/
-  创建build目录：
   1. mkdir build 
   2. cd build        
- 配置CMake（推荐安装到/opt/unitree_robotics）
 1. cmake .. -DCMAKE_INSTALL_PREFIX=/opt/unitree_robotics 
 2. sudo make install

## 4. **安装 MuJoCo**
### 在此链接找到对应版本下载：
https://github.com/google-deepmind/mujoco/releases
压缩包放在Ubuntu→home→用户名文件夹内 
### **解压到指定目录**
建议解压在home目录下：路径： /home/fiiiiiiine-rain/unitree_sdk2  
- 创建隐藏目录：mkdir -p ~/.mujoco
- 解压：tar -zxvf ~/mujoco-3.3.6-linux-x86_64.tar.gz -C ~/.mujoco
-  将解压后的文件夹移动：cd ~/.mujoco  
## 5. **创建符号链接**
- cd unitree_mujoco/simulate/
- ln -s ~/.mujoco/mujoco-3.3.6 mujoco （如果安装的是3.3.7或是其他版本注意调整）

## 6.**编译 unitree_mujoco**
- cd unitree_mujoco/simulate
  mkdir build && cd build
- 配置CMake：cmake ..
- 编译（使用4个线程）：make -j4
==如果make -j4不行：==
安装缺失的依赖库
sudo apt update
sudo apt install libfmt-dev libunwind-dev
安装完依赖后，回到你的  build  目录，重新执行编译命令。为了确保从一个干净的状态开始：
假设你已经在 .../simulate/build 目录下：
make clean（清理之前的编译产物）
make -j4
如果  make  命令成功执行且没有报错，可执行文件  unitree_mujoco  就会被生成。此时，你就可以运行它了：
./unitree_mujoco -r go2 -s scene_terrain.xml

