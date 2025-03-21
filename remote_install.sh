#!/bin/bash
#
# AdGuard试用期重置工具远程安装脚本
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
    print_warning "未安装sqlite3。这可能会影响重置功能。"
  fi

  print_success "所有必要的依赖检查通过。"
}

# 清理临时目录
cleanup() {
  if [ -d "$tmp_dir" ]; then
    rm -rf "$tmp_dir"
  fi
}

# 创建临时目录
setup_temp_dir() {
  tmp_dir=$(mktemp -d -t adguard-reset-XXXXXX)
  trap cleanup EXIT
  print_info "已创建临时目录: $tmp_dir"
}

# 下载脚本
download_scripts() {
  print_info "正在下载AdGuard试用期重置工具..."

  # GitHub原始链接 - 实际托管的URL
  GITHUB_RAW_URL="https://raw.githubusercontent.com/zhangzhangco/adguard-trial-reset/main"

  # 下载重置脚本
  curl -s -o "$tmp_dir/reset.sh" "$GITHUB_RAW_URL/scripts/reset.sh"
  curl -s -o "$tmp_dir/install.sh" "$GITHUB_RAW_URL/install.sh"

  # 检查下载是否成功
  if [ ! -f "$tmp_dir/reset.sh" ] || [ ! -f "$tmp_dir/install.sh" ]; then
    print_error "下载脚本失败。请检查您的网络连接后重试。"
    exit 1
  fi

  # 设置执行权限
  chmod +x "$tmp_dir/reset.sh"
  chmod +x "$tmp_dir/install.sh"

  print_success "脚本下载完成。"
}

# 设置目录结构
setup_directory_structure() {
  print_info "正在设置目录结构..."

  mkdir -p "$tmp_dir/scripts"
  mv "$tmp_dir/reset.sh" "$tmp_dir/scripts/"

  print_success "目录结构设置完成。"
}

# 执行安装
run_installer() {
  print_info "开始执行安装..."

  cd "$tmp_dir"
  ./install.sh

  install_status=$?
  if [ $install_status -ne 0 ]; then
    print_error "安装过程中发生错误。"
    exit $install_status
  fi

  print_success "安装程序已执行完成。"

  # 提示用户如何立即使用
  if ! command -v adguard-reset &> /dev/null; then
    print_info "您可以使用以下命令立即运行AdGuard试用期重置工具:"
    print_info "~/.adguard-reset/scripts/reset.sh"
  fi
}

# 主函数
main() {
  # 显示欢迎信息
  echo "======================================================"
  echo "    AdGuard试用期重置工具在线安装程序"
  echo "======================================================"
  echo ""

  # 检查操作系统
  check_os

  # 检查依赖
  check_dependencies

  # 创建临时目录
  setup_temp_dir

  # 下载脚本
  download_scripts

  # 设置目录结构
  setup_directory_structure

  # 执行安装
  run_installer

  echo ""
  echo "安装已完成！现在您可以使用 'adguard-reset' 命令重置AdGuard试用期。"
  echo "如果命令未找到，请尝试使用完整路径: ~/.adguard-reset/scripts/reset.sh"
}

# 执行主函数
main
