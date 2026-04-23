#!/bin/bash
# 功能: NodeScriptKit 安装和更新脚本 (个人定制修复版)

goos=$(uname -s | tr '[:upper:]' '[:lower:]')
goarch=$(uname -m)                        

echo "Current OS: $goos"
echo "Current Architecture: $goarch"

if [ "$goos" == "darwin" ]; then
    ext=""
elif [ "$goos" == "linux" ] || [ "$goos" == "freebsd" ]; then
    ext=""
else
    echo "Unsupported OS: $goos"
    exit 1
fi

if [ "$goarch" == "x86_64" ]; then
    arch="amd64"
elif [ "$goarch" == "i386" ]; then
    arch="386"
elif [ "$goarch" == "arm64" ]; then
    arch="arm64"
else
    echo "Unsupported Architecture: $goarch"
    exit 1
fi

# 【修复点1】：核心引擎找原作者 (NodeSeekDev) 下载，保证能下到真实的运行程序
BIN_VERSION="$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/NodeSeekDev/NskCore/releases/latest)"
BIN_VERSION=${BIN_VERSION##*/}
BIN_FILENAME="nskCore-$goos-$arch$ext"
BIN_URL="https://github.com/NodeSeekDev/NskCore/releases/download/$BIN_VERSION/$BIN_FILENAME"

curl -Lso /usr/bin/nskCore $BIN_URL
chmod u+x /usr/bin/nskCore

if tar --version 2>&1 | grep -qi 'busybox'; then
    if command -v apk >/dev/null 2>&1; then
        apk add --no-cache tar
    fi
fi

mkdir -p /etc/nsk/modules.d/default
mkdir -p /etc/nsk/modules.d/extend
# 确保脚本目录也存在
mkdir -p /etc/nsk/shell_scripts

cd /tmp
temp_dir=$(mktemp -d)

# 【修复点2】：不去找 Tags，直接下载你 main 分支的最新代码
echo "正在拉取最新菜单与脚本..."
curl -sLo - "https://github.com/dengsy1993/NodeScriptKit/archive/refs/heads/main.tar.gz" | \
    tar -xzv -C $temp_dir

# 复制配置文件
[ -f "/etc/nsk/config.toml" ] || cp $temp_dir/*/menu.toml /etc/nsk/config.toml

# 清理并复制最新菜单配置
rm -rf /etc/nsk/modules.d/default/* cp $temp_dir/*/modules.d/* /etc/nsk/modules.d/default/

# 【修复点3】：关键！把你写的脚本文件复制到运行目录，否则菜单点击会没反应
cp -r $temp_dir/*/shell_scripts/* /etc/nsk/shell_scripts/

# 固定版本号为 main，防止重复提示升级
echo "main" > /etc/nsk/version

# 替换启动命令
cp $temp_dir/*/nsk.sh /usr/bin/nsk
chmod u+x /usr/bin/nsk
[ -f "/usr/bin/n" ] || ln -s /usr/bin/nsk /usr/bin/n

rm -rf $temp_dir

echo -e "\e[1;32mnsk脚本安装成功啦，可以输入n或者nsk命令唤出菜单\e[0m"
