# 🛠️ NodeScriptKit (个人自用版)

本项目基于开源项目 [NodeScriptKit](https://github.com/NodeSeekDev/NodeScriptKit) 自行定制。

## 🚀 极速安装指南

一键安装脚本：

```bash
bash <(curl -Ls nsk-dengsy1993.qqvps.eu.org)
```
安装完成后，以后随时在终端输入 `nsk` 或 `n` 即可快速唤出工具箱。

## ✨ 新增功能

### 20260423更新
BBR 网络加速优化
集成了一键 TCP 调优工具，运行后会自动配置系统环境，之后支持直接在终端使用 bbr 指令唤出优化面板。

位置：`主菜单` -> `自用工具` -> `BBR 网络加速优化`

致谢：核心脚本源自 [Eric86777/vps-tcp-tune](https://github.com/Eric86777/vps-tcp-tune)

安装后只需输入 `bbr` 即可运行

## 📖 DIY 教程：如何增加自己的新脚本？

以后你遇到任何好用的脚本，只需三步就能把它装进你的专属菜单里，就像搭积木一样简单且不会和原版冲突：

### 第一步：上传脚本文件
1. 将你的 `.sh` 脚本上传到仓库的 `shell_scripts/custom/` 文件夹下。
2. 记下它的路径，例如：`shell_scripts/custom/my_test.sh`。

### 第二步：修改“自用”菜单配置
1. 进入 `modules.d/` 目录，打开你的专属配置文件 **`110-custom_tools.toml`**。
2. **定义脚本别名**：在顶部的 `[scripts]` 区域下方加一行：
   `my_script_cmd = "bash /etc/nsk/shell_scripts/custom/my_test.sh"`
3. **把按钮加入列表**：在第一个 `[[menus]]` (id = "custom_tools") 的 `sub_menus` 列表里，加上你的按钮 ID，比如 `'my_btn_item'`。
4. **设计按钮外观**：在文件最末尾，新增一个菜单块：
   ```toml
   [[menus]]
   id = "my_btn_item"
   title = "我的新脚本名字"
   script = "my_script_cmd"

(💡 防报错小贴士：菜单 ID 和脚本 Key 最好使用不同的后缀以防重名，例如按钮用 `_item`，命令用 `_cmd`。)

### 第三步：在 VPS 上强制同步
修改完 GitHub 后，登录你的 VPS，运行一次带时间戳的安装命令即可强制覆盖旧菜单：

```bash
bash <(curl -Ls "[https://raw.githubusercontent.com/dengsy1993/NodeScriptKit/main/install.sh?t=$](https://raw.githubusercontent.com/dengsy1993/NodeScriptKit/main/install.sh?t=$)(date +%s)")
```

上面两处 `dengsy1993`可改成你自己的

## ⚙️ 架构与底层说明
NodeScriptKit 是一个社区驱动的、交互式的服务器辅助脚本汇总集合。

核心目录映射
主程序：`/usr/bin/nsk` (链接自 `nsk.sh`)

核心引擎：`/usr/bin/nskCore`

主配置：`/etc/nsk/config.toml`

菜单定义：`/etc/nsk/modules.d/default/*.toml`

脚本存放：`/etc/nsk/shell_scripts/`

配置文件逻辑
合并机制：系统会对所有 `.toml` 文件进行逻辑合并，而非简单的文本拼接。

ID 穿针引线：`id` 负责关联菜单层级，`script` 负责最终落地到具体的 `Shell` 命令。


# 下面为原项目介绍
# NodeScriptKit
NodeScriptKit项目，简称nsk项目。它是
- 一个社区驱动的，命令小抄项目
- 一个可自由扩展配置，支持订阅，交互式的，服务器辅助脚本汇总集合
- 一个能够节省你大量命令/脚本查找时间的项目


![screenshot](./img/screenshot1.png)

## 主配置文件说明
- 配置文件采用[toml格式](https://toml.io/cn/v1.0.0)，可以使用[vscode](https://code.visualstudio.com/)配合[Even Better TOML](https://marketplace.visualstudio.com/items?itemName=tamasfe.even-better-toml)插件或者一些[在线编辑器](https://www.toml-lint.com/)编辑
- nsk的主配置文件默认位于/etc/nsk/config.toml
- 常用的配置入口包括[local]和[remote]，分别代表本地模块文件和远程订阅文件，本地和远程都可以合并/覆盖配置
- 合并配置toml解析后的对象合并，而非文本拼接
- 本地配置文件支持通配符，对匹配到的文件按文件名[自然排序](https://github.com/facette/natsort)后导入
- 默认`/etc/nsk/modules.d/default/*.toml`为官方模块，更新时会清空内容后再更新
- 默认`/etc/nsk/modules.d/extend/*.toml`为用户模块，更新菜单时不会清空内容
- 支持订阅，多个订阅链接会并发加载

## 模块配置文件说明
模块配置是用户打交道比较多的地方，内容包括脚本和菜单，菜单可以指向子菜单（们）和脚本

### 脚本示例
```
[scripts]
# 脚本集合，键值对
memory = "free -h"
disk = "df -hT"
cpuinfo = "cat /proc/cpuinfo"
whoami = "whoami"

hello = "echo \"hello world\""
yabs = "curl -sL yabs.sh | bash"
docker = "bash <(curl -sL 'https://get.docker.com')"

test = "echo '这是一个测试项'"
```

脚本部分比较简单，是一系列键值对，一个键对应一个字符串的值

### 菜单示例

```
[[menus]]
id = "main"
title = "主菜单"
sub_menus = [
    "info",
    "tool",
    "test"
]

[[menus]]
id = "info"
title = "系统信息"
sub_menus = [
    "cpu",
    "memory",
    "disk",
    "current-user",
]

[[menus]]
id = "test"
title = "测试项"
script = "test"
```

如上面所示，main菜单是入口菜单，有3个子菜单，其中info子菜单有进一步的子菜单，而test菜单没有下级，直接指向id为test的脚本

这些菜单id负责穿针引线，落叶归根到脚本id

## 扩展/覆盖配置的方式
NodeScriptKit支持合并配置文件且支持订阅远程配置，如果你是在本地调试，可以将新的配置文件放置到/etc/nsk/modules.d/extend/ 目录下，文件扩展名为toml

如果分享给其他用户，可以放到GitHub上并分享为raw文件直链，接受分享的用户可以修改/etc/nsk/config.toml中[remote]/subscribes的配置文本
下面给出一个示例配置，很容易看懂
```
[scripts]
test1 = "echo test1"

[[menus]]
id = "main"
title = "主菜单"
sub_menus = [
    "my-append", # 给主菜单补充新的入口
]

# 新的菜单入口
[[menus]]
id = "my-append"
title = "补充菜单"
sub_menus = [
    "test1",
]

[[menus]]
id = "test1"
title = "打印 test1"
script = "test1"
```

## 代码提交规范和约定
- 鼓励开发者通过pr贡献内容
- 提交的内容主要包括菜单和脚本，菜单放到modules.d下，脚本放到shell_scripts下
- 菜单类要以3位数字开头，安装优先级排序，数值大的内容可以合并/覆盖数值小的
- 脚本类尽量在文件开头写明代码脚本描述，可以参考这个[模板文件](./shell_scripts/example.v0.0.1.0417.sh)
- 脚本尽量使用交互式调用

## 社区公约&开发指南
- [原项目地址](https://github.com/NodeSeekDev/NodeScriptKit)
- [社区公约](./Development.md)
- [开发指南](./Rules.md)
