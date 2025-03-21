# AdGuard试用期重置工具

这是一个用于重置AdGuard for Mac试用期的小工具，通过简单命令即可轻松重置14天试用期限制。

## 特性

- 自动检测AdGuard安装位置
- 自动备份许可证数据
- 自动重置试用期
- 支持命令行参数
- 支持远程一键安装
- 智能PATH环境变量配置

## 安装方法

### 方法一：使用curl（推荐）

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zhangzhangco/adguard-trial-reset/main/remote_install.sh)"
```

### 方法二：使用wget

```bash
bash -c "$(wget -O- https://raw.githubusercontent.com/zhangzhangco/adguard-trial-reset/main/remote_install.sh)"
```

### 方法三：手动安装

1. 克隆仓库
   ```bash
   git clone https://github.com/zhangzhangco/adguard-trial-reset.git
   ```

2. 进入目录并运行安装脚本
   ```bash
   cd adguard-trial-reset
   bash install.sh
   ```

## 使用方法

### 命令访问

安装完成后，您可以通过以下方式访问命令：

1. 直接使用命令（如果PATH配置正确）：
   ```bash
   adguard-reset
   ```

2. 使用完整路径：
   ```bash
   ~/.adguard-reset/scripts/reset.sh
   ```

3. 如果安装时显示PATH未配置，请按照提示执行：
   ```bash
   source ~/.zshrc  # 或您的shell配置文件
   ```

### 基本命令

#### 重置AdGuard试用期

```bash
adguard-reset
```

#### 重置后自动启动AdGuard

```bash
adguard-reset -s
```

#### 恢复最近的备份

```bash
adguard-reset -r
```

#### 显示帮助信息

```bash
adguard-reset -h
```

### 定时任务

#### 设置每周自动重置

使用cron设置定时任务：

```bash
# 编辑crontab
crontab -e

# 添加以下行（每周一凌晨2点重置）
0 2 * * 1 ~/.adguard-reset/scripts/reset.sh -s
```

#### 使用LaunchAgent（仅macOS）

1. 创建LaunchAgent文件：
   ```bash
   mkdir -p ~/Library/LaunchAgents
   cat > ~/Library/LaunchAgents/com.user.adguardreset.plist << 'EOF'
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.user.adguardreset</string>
       <key>ProgramArguments</key>
       <array>
           <string>~/.adguard-reset/scripts/reset.sh</string>
           <string>-s</string>
       </array>
       <key>StartCalendarInterval</key>
       <dict>
           <key>Day</key>
           <integer>1</integer>
           <key>Hour</key>
           <integer>2</integer>
           <key>Minute</key>
           <integer>0</integer>
       </dict>
   </dict>
   </plist>
   EOF
   ```

2. 加载LaunchAgent：
   ```bash
   launchctl load ~/Library/LaunchAgents/com.user.adguardreset.plist
   ```

## 常见问题

### "找不到adguard-reset命令"

**症状**：安装后输入`adguard-reset`命令，提示"command not found"。

**解决方法**：

1. 使用完整路径执行：`~/.adguard-reset/scripts/reset.sh`

2. 将`~/bin`添加到PATH中（如果安装脚本未能自动添加）：
   ```bash
   # 添加以下行到~/.zshrc、~/.bashrc或~/.bash_profile
   export PATH="$HOME/bin:$PATH"

   # 然后运行
   source ~/.zshrc  # 或您对应的配置文件
   ```

3. 重新安装最新版本，已增强自动PATH配置功能
   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/zhangzhangco/adguard-trial-reset/main/remote_install.sh)"
   ```

### "权限被拒绝"

**症状**：执行命令时出现"permission denied"错误。

**解决方法**：
```bash
chmod +x ~/.adguard-reset/scripts/reset.sh
```

## 卸载方法

如果您想卸载此工具，可以执行以下命令：

```bash
# 删除安装目录
rm -rf ~/.adguard-reset

# 删除命令链接
rm -f ~/bin/adguard-reset
rm -f /usr/local/bin/adguard-reset 2>/dev/null || sudo rm -f /usr/local/bin/adguard-reset 2>/dev/null
rm -f ~/.local/bin/adguard-reset 2>/dev/null

# 如果您设置了定时任务，记得删除
crontab -l | grep -v "adguard-reset" | crontab -

# 如果您设置了LaunchAgent，记得卸载
launchctl unload ~/Library/LaunchAgents/com.user.adguardreset.plist 2>/dev/null
rm -f ~/Library/LaunchAgents/com.user.adguardreset.plist 2>/dev/null
```

## 更新日志

### v1.0.1
- 增加智能PATH环境变量配置功能
- 改进安装后的用户引导体验
- 修复"command not found"问题
- 优化shell配置文件自动识别

### v1.0.0
- 首次发布
- 支持AdGuard试用期重置
- 支持远程一键安装
- 自动备份与恢复功能

## 免责声明

此工具仅供学习和研究目的使用。使用此工具可能违反AdGuard的服务条款。请支持正版软件，有能力的用户请购买AdGuard的正式授权。
