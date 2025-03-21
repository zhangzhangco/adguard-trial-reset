#!/bin/bash
#
# AdGuard试用期重置工具安装脚本
# 作者：AdGuard-Reset-Tool
# 版本：1.0.0
#

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 打印带颜色的信息
print_info() {
  echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
  echo -e "${RED}[错误]${NC} $1"
}

# 检查操作系统
check_os() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "此脚本仅适用于macOS系统。"
    exit 1
  fi

  print_info "操作系统检查通过。"
}

# 检查必要的依赖
check_dependencies() {
  print_info "检查必要的依赖..."

  # 检查curl
  if ! command -v curl &> /dev/null; then
    print_error "未安装curl。请先安装curl后再继续。"
    exit 1
  fi

  # 检查sqlite3
  if ! command -v sqlite3 &> /dev/null; then
    print_warning "未安装sqlite3。这可能会影响脚本的某些功能。"
  fi

  print_success "所有必要的依赖检查通过。"
}

# 创建安装目录
create_install_dir() {
  # 创建安装目录
  install_dir=~/.adguard-reset
  mkdir -p $install_dir/scripts

  print_info "已创建安装目录: $install_dir"
}

# 下载最新的重置脚本
download_scripts() {
  print_info "正在下载最新版本的AdGuard试用期重置脚本..."

  # GitHub原始链接 - 这里是实际托管的URL
  GITHUB_RAW_URL="https://raw.githubusercontent.com/zhangzhangco/adguard-trial-reset/main"

  # 下载重置脚本
  curl -s -o $install_dir/scripts/reset.sh $GITHUB_RAW_URL/scripts/reset.sh

  # 检查下载是否成功
  if [ $? -ne 0 ]; then
    print_error "下载脚本失败。请检查您的网络连接后重试。"
    exit 1
  fi

  # 设置执行权限
  chmod +x $install_dir/scripts/reset.sh

  print_success "脚本下载完成。"
}

# 创建命令链接
create_command_link() {
  print_info "正在创建命令链接..."

  # 创建bin目录（如果不存在）
  mkdir -p ~/bin

  # 创建重置命令链接
  cat > ~/bin/adguard-reset << 'EOF'
#!/bin/bash
~/.adguard-reset/scripts/reset.sh "$@"
EOF

  # 设置执行权限
  chmod +x ~/bin/adguard-reset

  # 检查PATH中是否包含~/bin
  if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    print_warning "~/bin 不在您的PATH环境变量中。"
    print_info "请将以下行添加到您的~/.bashrc或~/.zshrc文件中："
    print_info "export PATH=\"\$HOME/bin:\$PATH\""
  fi

  print_success "命令链接创建完成。"
}

# 显示使用说明
show_usage() {
  cat << 'EOF'

====================================================
    AdGuard试用期重置工具安装完成！
====================================================

使用方法:

1. 重置AdGuard试用期:
   $ adguard-reset

2. 重置后自动启动AdGuard:
   $ adguard-reset -s

3. 恢复最近的备份:
   $ adguard-reset -r

4. 显示帮助信息:
   $ adguard-reset -h

每当AdGuard试用期即将结束时，运行此命令可以再次获得14天的试用期。

如果你在使用中遇到任何问题，请访问:
https://github.com/zhangzhangco/adguard-trial-reset

祝您使用愉快！
EOF
}

# 离线安装
offline_install() {
  print_info "正在进行离线安装..."

  # 创建安装目录
  create_install_dir

  # 复制重置脚本
  cp ./scripts/reset.sh $install_dir/scripts/reset.sh
  chmod +x $install_dir/scripts/reset.sh

  # 创建命令链接
  create_command_link

  print_success "离线安装完成。"
}

# 在线安装
online_install() {
  print_info "正在进行在线安装..."

  # 检查操作系统
  check_os

  # 检查依赖
  check_dependencies

  # 创建安装目录
  create_install_dir

  # 下载脚本
  download_scripts

  # 创建命令链接
  create_command_link

  print_success "在线安装完成。"
}

# 主函数
main() {
  echo "======================================================"
  echo "    AdGuard试用期重置工具安装程序"
  echo "======================================================"
  echo ""

  # 检查是否是离线安装
  if [ -f "./scripts/reset.sh" ]; then
    offline_install
  else
    online_install
  fi

  # 显示使用说明
  show_usage
}

# 执行主函数
main
