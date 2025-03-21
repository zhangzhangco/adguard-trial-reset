#!/bin/bash
#
# AdGuard试用期重置工具远程安装脚本
# 作者：AdGuard-Reset-Tool
# 版本：1.0.1
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

# 检查PATH环境变量
check_path() {
  local bin_dirs=("/usr/local/bin" "$HOME/.local/bin" "$HOME/bin")
  local path_updated=0
  local detected_shell=""
  local rc_file=""

  # 检测当前shell
  if [[ "$SHELL" == *"zsh"* ]]; then
    detected_shell="zsh"
    rc_file="$HOME/.zshrc"
  elif [[ "$SHELL" == *"bash"* ]]; then
    detected_shell="bash"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      rc_file="$HOME/.bash_profile"
    else
      rc_file="$HOME/.bashrc"
    fi
  fi

  # 检查PATH中是否包含bin目录
  local path_contains_bin=false
  for dir in "${bin_dirs[@]}"; do
    if [[ -d "$dir" && ":$PATH:" == *":$dir:"* ]]; then
      path_contains_bin=true
      break
    fi
  done

  # 如果PATH中不包含任何bin目录，并且检测到了shell配置文件
  if [[ "$path_contains_bin" == false && -n "$rc_file" ]]; then
    print_warning "您的PATH中没有包含AdGuard重置工具的命令目录"

    # 检查我们是否已经安装到了$HOME/bin
    if [[ -d "$HOME/bin" && -f "$HOME/bin/adguard-reset" ]]; then
      # 向shell配置文件添加PATH
      echo -e "\n# AdGuard重置工具命令路径\nexport PATH=\"\$HOME/bin:\$PATH\"" >> "$rc_file"
      print_info "已将 $HOME/bin 添加到您的PATH环境变量中"
      path_updated=1
    fi
  fi

  return $path_updated
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
}

# 显示安装后说明
show_post_install_instructions() {
  local need_source=0
  local rc_file=""

  # 检测当前shell配置文件
  if [[ "$SHELL" == *"zsh"* ]]; then
    rc_file="$HOME/.zshrc"
  elif [[ "$SHELL" == *"bash"* ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      rc_file="$HOME/.bash_profile"
    else
      rc_file="$HOME/.bashrc"
    fi
  fi

  # 检查PATH是否已更新
  check_path
  need_source=$?

  echo -e "\n${GREEN}===================================================="
  echo "    AdGuard试用期重置工具安装完成！"
  echo -e "====================================================${NC}"

  # 检查命令是否可用
  if ! command -v adguard-reset &> /dev/null; then
    echo -e "\n${YELLOW}提示：${NC}"
    echo "命令 'adguard-reset' 不在当前PATH中。您可以："

    if [[ "$need_source" -eq 1 && -n "$rc_file" ]]; then
      echo -e "1. 运行以下命令使配置生效：\n   ${GREEN}source $rc_file${NC}"
      echo -e "2. 重新打开终端窗口"
    else
      echo -e "1. 使用以下完整路径运行命令：\n   ${GREEN}~/.adguard-reset/scripts/reset.sh${NC}"

      if [[ -n "$rc_file" ]]; then
        echo -e "2. 手动添加命令到PATH，在 $rc_file 中添加：\n   ${GREEN}export PATH=\"\$HOME/bin:\$PATH\"${NC}"
        echo -e "   然后运行：${GREEN}source $rc_file${NC}"
      fi
    fi

    echo -e "\n如果您在使用中遇到任何问题，请访问："
    echo -e "${BLUE}https://github.com/zhangzhangco/adguard-trial-reset${NC}"
  else
    echo -e "\n您现在可以直接使用 ${GREEN}adguard-reset${NC} 命令重置AdGuard试用期。"
    echo -e "运行 ${GREEN}adguard-reset -h${NC} 查看使用帮助。"
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

  # 显示安装后说明
  show_post_install_instructions
}

# 执行主函数
main
