#!/bin/bash
# 功能: NodeScriptKit 终极兼容版安装脚本

goos=$(uname -s | tr '[:upper:]' '[:lower:]')
goarch=$(uname -m)

if [ "$goarch" == "x86_64" ]; then arch="amd64"
elif [ "$goarch" == "arm64" ]; then arch="arm64"
else arch="amd64"; fi # 默认为 amd64

# 1. 下载核心引擎（找原作者下载真实的运行程序）
BIN_VERSION="$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/NodeSeekDev/NskCore/releases/latest)"
BIN_VERSION=${BIN_VERSION##*/}
BIN_URL="https://github.com/NodeSeekDev/NskCore/releases/download/$BIN_VERSION/nskCore-$goos-$arch"

curl -Lso /usr/bin/nskCore $BIN_URL
chmod u+x /usr/bin/nskCore

# 2. 准备目录
mkdir -p /etc/nsk/modules.d/default
mkdir -p /etc/nsk/modules.d/extend
mkdir -p /etc/nsk/shell_scripts

# 3. 拉取你的 GitHub 代码
cd /tmp
temp_dir=$(mktemp -d)
echo "正在拉取最新的自定义菜单与脚本..."
curl -sLo - "https://github.com/dengsy1993/NodeScriptKit/archive/refs/heads/main.tar.gz" | tar -xzv -C $temp_dir

# 4. 【核心修复】：强制更新主配置文件
# 这里的 config.toml 必须包含正确的模块搜索路径
cp -f $temp_dir/*/menu.toml /etc/nsk/config.toml

# 5. 【核心修复】：分行执行，确保菜单和脚本被正确复制
rm -rf /etc/nsk/modules.d/default/*
cp -r $temp_dir/*/modules.d/* /etc/nsk/modules.d/default/
cp -r $temp_dir/*/shell_scripts/* /etc/nsk/shell_scripts/

# 6. 设置版本并安装启动命令
echo "main" > /etc/nsk/version
cp $temp_dir/*/nsk.sh /usr/bin/nsk
chmod u+x /usr/bin/nsk
[ -f "/usr/bin/n" ] || ln -s /usr/bin/nsk /usr/bin/n

rm -rf $temp_dir
echo -e "\e[1;32m安装成功！请输入 n 或 nsk 唤出菜单。\e[0m"
