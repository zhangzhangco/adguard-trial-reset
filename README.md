# AdGuard 试用期重置工具

![版本](https://img.shields.io/badge/版本-1.0.0-blue.svg)
![平台](https://img.shields.io/badge/平台-macOS-lightgrey.svg)
![许可证](https://img.shields.io/badge/许可证-MIT-green.svg)

**AdGuard 试用期重置工具**是一个开源项目，帮助用户重置 AdGuard for Mac 的试用期，让您可以持续体验 AdGuard 的全部功能。

> ⚠️ **免责声明**：本工具仅供学习和研究目的。使用本工具可能违反 AdGuard 的服务条款。我们强烈建议用户购买正版 AdGuard 许可证以支持开发者。

## 功能特点

- 一键重置 AdGuard 试用期
- 自动备份重要数据
- 支持恢复之前的备份
- 完全开源，代码透明
- 简单易用的命令行界面
- 自动检测和关闭 AdGuard 进程
- 适用于 macOS 系统

## 安装方法

### 方法一：使用 curl 命令安装（推荐）

打开终端，执行以下命令：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zhangzhangco/adguard-trial-reset/main/remote_install.sh)"
```

### 方法二：使用 wget 命令安装

```bash
bash -c "$(wget -O- https://raw.githubusercontent.com/zhangzhangco/adguard-trial-reset/main/remote_install.sh)"
```

### 方法三：手动安装

1. 克隆或下载此仓库
   ```bash
   git clone https://github.com/zhangzhangco/adguard-trial-reset.git
   ```
2. 打开终端，进入下载目录
   ```bash
   cd adguard-trial-reset
   ```
3. 执行 `chmod +x install.sh && ./install.sh`

## 使用方法

安装完成后，您可以通过以下命令使用：

### 重置 AdGuard 试用期

```bash
adguard-reset
```

### 重置后自动启动 AdGuard

```bash
adguard-reset -s
```

### 恢复最近的备份

```bash
adguard-reset -r
```

### 显示帮助信息

```bash
adguard-reset -h
```

## 工作原理

本工具通过以下步骤重置 AdGuard 的试用期：

1. 关闭所有 AdGuard 相关进程
2. 备份当前的数据库和首选项文件
3. 清除许可证数据
4. 重置首选项中的试用期相关信息
5. 清除缓存和临时文件
6. 重新启动 AdGuard（可选）

## 常见问题解答

### 重置后无法获得 14 天完整试用期怎么办？

有时 AdGuard 可能会记住您的设备或账户信息。尝试以下方法：

1. 确保使用管理员权限运行脚本
2. 尝试在重置前先完全卸载 AdGuard，然后重新安装
3. 使用 `-r` 参数恢复到之前的备份

### 脚本运行后出现错误提示

可能的原因和解决方法：

1. 确保您的系统是 macOS
2. 确保已安装 sqlite3（大多数 macOS 系统默认已安装）
3. 确保 `~/bin` 目录在您的 PATH 环境变量中

### 每次重置都要手动运行命令太麻烦了

您可以设置定时任务自动运行重置脚本：

```bash
# 编辑 crontab
crontab -e

# 添加以下行（每月 1 日凌晨 3 点运行重置脚本）
0 3 1 * * ~/bin/adguard-reset -s
```

## 卸载方法

如果您不再需要此工具，可以通过以下命令卸载：

```bash
rm -rf ~/.adguard-reset
rm ~/bin/adguard-reset
```

## 贡献

欢迎提交 Pull Request 或提出 Issue。

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。
