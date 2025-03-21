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

# 创建命令链接到系统路径
create_command_link() {
  print_info "正在创建命令链接..."

  # 尝试几个可能的目录，按优先级排序
  DIRS_TO_TRY=(
    "/usr/local/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
  )

  INSTALL_CMD="adguard-reset"
  CREATED=false

  for DIR in "${DIRS_TO_TRY[@]}"; do
    # 检查目录是否存在且在PATH中
    if [ -d "$DIR" ] && [[ ":$PATH:" == *":$DIR:"* ]]; then
      # 尝试在该目录创建链接
      if [ ! -w "$DIR" ]; then
        # 如果没有写权限，需要sudo
        print_info "需要管理员权限才能在 $DIR 创建命令链接"
        print_info "请输入您的密码（如果提示）:"
        if sudo sh -c "cat > $DIR/$INSTALL_CMD << 'EOF'
#!/bin/bash
~/.adguard-reset/scripts/reset.sh \"\$@\"
EOF
chmod +x $DIR/$INSTALL_CMD"; then
          print_success "已在 $DIR 创建命令链接（需要管理员权限）"
          CREATED=true
          break
        else
          print_warning "在 $DIR 创建命令链接失败，尝试其他位置"
        fi
      else
        # 如果有写权限，直接创建
        cat > "$DIR/$INSTALL_CMD" << 'EOF'
#!/bin/bash
~/.adguard-reset/scripts/reset.sh "$@"
EOF
        chmod +x "$DIR/$INSTALL_CMD"
        print_success "已在 $DIR 创建命令链接"
        CREATED=true
        break
      fi
    elif [ ! -d "$DIR" ]; then
      # 目录不存在，尝试创建
      if mkdir -p "$DIR" 2>/dev/null; then
        cat > "$DIR/$INSTALL_CMD" << 'EOF'
#!/bin/bash
~/.adguard-reset/scripts/reset.sh "$@"
EOF
        chmod +x "$DIR/$INSTALL_CMD"

        # 如果是创建的用户目录，添加到PATH
        if [[ "$DIR" == "$HOME"* && ":$PATH:" != *":$DIR:"* ]]; then
          # 添加到shell配置
          SHELL_RC=""
          if [ -f "$HOME/.zshrc" ]; then
            SHELL_RC="$HOME/.zshrc"
          elif [ -f "$HOME/.bashrc" ]; then
            SHELL_RC="$HOME/.bashrc"
          elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_RC="$HOME/.bash_profile"
          fi

          if [ -n "$SHELL_RC" ]; then
            echo "export PATH=\"$DIR:\$PATH\"" >> "$SHELL_RC"
            print_info "已将 $DIR 添加到PATH中（在 $SHELL_RC）"
            print_info "请运行 'source $SHELL_RC' 或重新打开终端以使更改生效"
          else
            print_warning "未找到shell配置文件，请手动将 $DIR 添加到PATH中"
          fi
        fi

        print_success "已在 $DIR 创建命令链接"
        CREATED=true
        break
      fi
    fi
  done

  # 如果所有尝试都失败，则回退到最简单的方法
  if [ "$CREATED" = false ]; then
    # 创建用户bin目录（如果不存在）
    mkdir -p ~/bin

    # 创建重置命令链接
    cat > ~/bin/adguard-reset << 'EOF'
#!/bin/bash
~/.adguard-reset/scripts/reset.sh "$@"
EOF

    # 设置执行权限
    chmod +x ~/bin/adguard-reset

    print_warning "已在 ~/bin 创建命令链接，但这个目录不在您的PATH中"
    print_info "要直接使用'adguard-reset'命令，请将以下行添加到您的shell配置文件中:"
    print_info "export PATH=\"\$HOME/bin:\$PATH\""
    print_info "或者您可以使用完整路径运行: ~/.adguard-reset/scripts/reset.sh"
  else
    # 创建一个方便的别名，以防万一
    mkdir -p ~/bin 2>/dev/null
    if [ -d ~/bin ]; then
      ln -sf ~/.adguard-reset/scripts/reset.sh ~/bin/adguard-reset 2>/dev/null
      chmod +x ~/bin/adguard-reset 2>/dev/null
    fi
  fi
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
