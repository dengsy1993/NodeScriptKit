#!/bin/bash
# 自动执行你提供的 BBR 优化脚本
echo "正在安装 VPS 网络优化脚本 (BBR)..."
bash <(curl -fsSL "https://raw.githubusercontent.com/Eric86777/vps-tcp-tune/main/install-alias.sh?$(date +%s)")

# 提示用户
echo "------------------------------------------------"
echo "安装完成！请注意："
echo "1. 系统配置已更新。"
echo "2. 建议退出当前 SSH 窗口并重连，或者手动执行 'source ~/.bashrc'。"
echo "3. 之后你可以直接在命令行输入 'bbr' 来使用该工具。"
echo "------------------------------------------------"
read -p "按回车键返回主菜单..."
