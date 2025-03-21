#!/bin/bash
#
# AdGuard试用期重置脚本
# 此脚本用于重置AdGuard的试用期，延长使用时间
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

# 检查是否已安装AdGuard
check_adguard_installed() {
  if [ ! -d "/Applications/AdGuard.app" ]; then
    print_error "未找到AdGuard应用程序。请确保已安装AdGuard。"
    exit 1
  fi

  print_success "已找到AdGuard应用程序。"
}

# 关闭AdGuard所有相关进程
close_adguard() {
  print_info "正在尝试关闭AdGuard所有相关进程..."
  killall "Adguard" 2>/dev/null
  killall "adguard-nm" 2>/dev/null
  killall "com.adguard.mac.adguard.network-extension" 2>/dev/null
  sleep 2

  # 确保进程完全关闭
  if pgrep -i "Adguard" > /dev/null; then
    print_warning "AdGuard进程仍在运行，尝试强制关闭..."
    killall -9 "Adguard" 2>/dev/null
    killall -9 "adguard-nm" 2>/dev/null
    killall -9 "com.adguard.mac.adguard.network-extension" 2>/dev/null
    sleep 1
  fi
}

# 创建备份
create_backup() {
  timestamp=$(date +%Y%m%d%H%M%S)
  backup_dir=~/.adguard-reset/backup_$timestamp
  mkdir -p $backup_dir

  print_info "正在创建备份..."

  # 备份数据库
  if [ -f ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/adguard.db ]; then
    cp -f ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/adguard.db $backup_dir/adguard.db.backup
    print_info "已备份数据库。"
  else
    print_warning "未找到AdGuard数据库文件。"
  fi

  # 备份首选项
  if [ -f ~/Library/Preferences/com.adguard.mac.adguard.plist ]; then
    cp -f ~/Library/Preferences/com.adguard.mac.adguard.plist $backup_dir/com.adguard.mac.adguard.plist.backup
    print_info "已备份首选项文件。"
  else
    print_warning "未找到AdGuard首选项文件。"
  fi

  # 备份产品信息
  if [ -f ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/product.info ]; then
    cp -f ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/product.info $backup_dir/product.info.backup
    print_info "已备份产品信息文件。"
  else
    print_warning "未找到产品信息文件。"
  fi

  # 保存备份路径到配置文件
  echo $backup_dir > ~/.adguard-reset/last_backup_path

  return 0
}

# 重置许可证数据
reset_license_data() {
  print_info "正在重置许可证数据..."
  if [ -f ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/adguard.db ]; then
    # 清空许可证数据
    sqlite3 ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/adguard.db "UPDATE license SET licenseData = NULL WHERE id=0;"
    print_success "已清空许可证数据。"
    return 0
  else
    print_error "未找到AdGuard数据库文件，无法重置许可证。"
    return 1
  fi
}

# 重置首选项文件
reset_preferences() {
  print_info "正在重置首选项中的试用期信息..."
  if [ -f ~/Library/Preferences/com.adguard.mac.adguard.plist ]; then
    # 删除与试用期和许可证相关的所有键
    defaults delete ~/Library/Preferences/com.adguard.mac.adguard.plist FirstSuccessfulStartedDate 2>/dev/null || true
    defaults delete ~/Library/Preferences/com.adguard.mac.adguard.plist trialActivated 2>/dev/null || true
    defaults delete ~/Library/Preferences/com.adguard.mac.adguard.plist licenseInfo 2>/dev/null || true
    defaults delete ~/Library/Preferences/com.adguard.mac.adguard.plist activationDate 2>/dev/null || true
    defaults delete ~/Library/Preferences/com.adguard.mac.adguard.plist licenseKey 2>/dev/null || true

    # 重新设置为新的试用激活
    defaults write ~/Library/Preferences/com.adguard.mac.adguard.plist trialActivated -bool true
    print_success "已重置首选项文件中的试用期信息。"
    return 0
  else
    print_warning "未找到AdGuard首选项文件，跳过此步骤。"
    return 1
  fi
}

# 清除缓存和临时文件
clear_cache() {
  print_info "正在清除所有缓存和临时文件..."

  # 删除产品信息文件
  if [ -f ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/product.info ]; then
    rm -f ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/product.info
    print_info "已删除产品信息文件。"
  fi

  # 清除flags目录
  rm -rf ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/flags/* 2>/dev/null
  print_info "已清除flags目录。"

  # 清除应用状态
  rm -rf ~/Library/Saved\ Application\ State/com.adguard.mac.adguard.savedState/* 2>/dev/null
  print_info "已清除应用状态。"

  # 清除临时存储目录
  rm -rf ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/TmpStorage/* 2>/dev/null
  print_info "已清除临时存储。"

  return 0
}

# 启动AdGuard
start_adguard() {
  if [[ "$1" == "yes" ]]; then
    open /Applications/AdGuard.app
    print_info "AdGuard已启动，请等待几秒钟让它完成初始化..."
    print_info "新的试用期已激活！"
  else
    print_info "请稍后手动启动AdGuard以激活新的试用期。"
  fi
}

# 恢复备份
restore_backup() {
  if [ ! -f ~/.adguard-reset/last_backup_path ]; then
    print_error "未找到备份路径记录。"
    return 1
  fi

  backup_dir=$(cat ~/.adguard-reset/last_backup_path)

  if [ ! -d "$backup_dir" ]; then
    print_error "备份目录不存在: $backup_dir"
    return 1
  fi

  print_info "正在从 $backup_dir 恢复备份..."

  # 恢复数据库
  if [ -f "$backup_dir/adguard.db.backup" ]; then
    cp -f "$backup_dir/adguard.db.backup" ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/adguard.db
    print_info "已恢复数据库。"
  fi

  # 恢复首选项
  if [ -f "$backup_dir/com.adguard.mac.adguard.plist.backup" ]; then
    cp -f "$backup_dir/com.adguard.mac.adguard.plist.backup" ~/Library/Preferences/com.adguard.mac.adguard.plist
    print_info "已恢复首选项文件。"
  fi

  # 恢复产品信息
  if [ -f "$backup_dir/product.info.backup" ]; then
    cp -f "$backup_dir/product.info.backup" ~/Library/Group\ Containers/TC3Q7MAJXF.com.adguard.mac/Library/Application\ Support/com.adguard.mac.adguard/product.info
    print_info "已恢复产品信息文件。"
  fi

  print_success "备份恢复完成。"
  return 0
}

# 解析命令行参数
parse_args() {
  # 默认不启动AdGuard
  start_app="no"

  # 检查是否有-s或--start参数
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -s|--start) start_app="yes"; shift ;;
      -r|--restore) do_restore="yes"; shift ;;
      -h|--help) show_help; exit 0 ;;
      *) echo "未知参数: $1"; show_help; exit 1 ;;
    esac
  done
}

# 显示帮助信息
show_help() {
  echo "AdGuard试用期重置工具"
  echo ""
  echo "用法: $0 [选项]"
  echo ""
  echo "选项:"
  echo "  -s, --start     重置后自动启动AdGuard"
  echo "  -r, --restore   恢复最近的备份"
  echo "  -h, --help      显示此帮助信息"
  echo ""
  echo "示例:"
  echo "  $0              重置AdGuard试用期"
  echo "  $0 -s           重置AdGuard试用期并自动启动AdGuard"
  echo "  $0 -r           恢复最近的备份"
}

# 主函数
main() {
  # 创建配置目录
  mkdir -p ~/.adguard-reset

  # 解析命令行参数
  parse_args "$@"

  # 如果需要恢复备份，则执行恢复操作后退出
  if [[ "$do_restore" == "yes" ]]; then
    restore_backup
    exit $?
  fi

  # 检查操作系统
  check_os

  # 检查是否已安装AdGuard
  check_adguard_installed

  # 关闭AdGuard
  close_adguard

  # 创建备份
  create_backup

  # 重置许可证数据
  reset_license_data
  if [[ $? -ne 0 ]]; then
    print_error "重置许可证数据失败，正在退出..."
    exit 1
  fi

  # 重置首选项
  reset_preferences

  # 清除缓存
  clear_cache

  print_success "AdGuard试用期重置成功！"
  print_info "每当AdGuard试用期即将结束时，运行此脚本可再次获得14天试用期。"

  # 启动AdGuard
  start_adguard "$start_app"

  exit 0
}

# 执行主函数，传递所有命令行参数
main "$@"
