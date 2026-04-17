# AGENTS.md

This document provides guidelines for agentic coding agents working in this dotfiles repository.

## 项目概述

dotfiles 仓库，包含以下配置和工具：
- Shell（zsh、bash 脚本）
- Vim/Neovim（配置、插件、Lua 脚本）
- Tmux（配置、状态栏脚本）
- Python 工具脚本
- C/C++ 工具（macOS 系统监控）
- 各类应用配置（kitty、bat、btop、fcitx5 等）

## 构建/检查命令

| 类型 | 命令 |
|------|------|
| 安装 | `./install.sh` |
| macOS 工具 | `cd osx && make`（构建 `simple_net`、`simple_cpu`、`simple_mem` 到 `$HOME/bin/`） |
| Shell 检查 | `shellcheck <script.sh>` 或 `bash -n <script.sh>` |
| Python 检查 | `python3 -m py_compile <file.py>` |
| Lua 检查 | `luac -p <file.lua>` |
| C/C++ 构建 | `make -f makefile/cxx.mk` |

## 代码风格

### Bash 脚本

**Shebang 和头部：**
```bash
#!/usr/bin/env bash
#
# @author   Name <email>
# @date     YYYY-MM-DD
# @version  1.0
# @license  GPL-2.0+

set -euo pipefail
```

- 函数/变量：`snake_case`；常量：`UPPER_SNAKE_CASE`
- 函数定义：`function function_name() { local var="value"; }`
- 跨平台路径：Darwin 用 `greadlink -f`，Linux 用 `readlink -f`
- 检查命令存在：`if hash nvim 2>/dev/null; then`
- 检查命令路径：`if _loc="$(type -p "cmd")" && [[ -n $_loc ]]; then`
- 符号链接：`ln -s "$target" "$link_name"`

### Python

**Shebang 和头部：**
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# @author   Name <email>
# @date     YYYY-MM-DD
# @version  1.0
# @license  GPL-2.0+
```

- 导入顺序：标准库 → 第三方 → 本地模块
- 函数/变量：`snake_case`；常量：`UPPER_SNAKE_CASE`
- 可选结果返回 `None`，用 `if not var:` 检查

### C++

- 类名：`PascalCase`（如 `MachProcessorInfo`）
- 方法：`snake_case`
- 成员变量：`snake_case_`（尾部下划线）
- 头文件顺序：系统头文件 → C++ 标准库 → 本地头文件

```cpp
class ClassName {
 public:
  ClassName() {}
  virtual ~ClassName() {}
  void method_name();
 private:
  int member_var_;
};
```

### Vim/Neovim

**Vimscript：**
- Leader：`\`（mapleader），`,`（localleader）
- 缩进：4 空格（html/xml/yaml/json/lua 用 2）
- 注释：`"` 前缀

**Lua：**
```lua
local api = vim.api

local M = {}

function M.function_name()
  ...
end

return M
```

### Makefiles

```makefile
.SUFFIXES: .cpp .c

NAME = a
CXX = g++
CXXFLAGS = -Wall -fpic -g -c -std=gnu++11
CXXSRC = $(wildcard ./*.cpp)
CXXOBJ = $(CXXSRC:%.cpp=%-cpp.o)

.PHONY:
clean:
	-rm *.d *.o $(NAME).out
```

## 目录结构

```
dotfiles/
├── config/     # 应用配置（zsh、kitty、bat 等）
├── install.sh  # 主安装脚本
├── makefile/   # 可复用 Makefile 模板
├── osx/        # macOS 工具（C++）
├── python/     # Python 工具脚本
├── shell/      # Shell 脚本和工具
├── tmux/       # Tmux 配置和状态脚本
└── vim/        # Vim/Neovim 配置
```

## 错误处理

### Shell 脚本
- 必须使用 `set -euo pipefail`
- 检查命令存在：`if _loc="$(type -p "cmd")" && [[ -n $_loc ]]; then`

### Python
- 可选结果返回 `None`
- 用 `if not var:` 显式检查 None

## 常用模式

**检查可执行文件：**
```bash
if hash nvim 2>/dev/null; then
    ...
fi
```

**创建符号链接：**
```bash
ln -s "$target" "$link_name"
```

**操作系统检测：**
```bash
if _loc="$(uname)" && [[ "$_loc" == "Darwin" ]]; then
    # macOS 代码
else
    # Linux 代码
fi
```

## Agent 偏好

- 项目记忆统一写入 AGENTS.md，分类详细记忆存放在 `./memory/` 目录，AGENTS.md 中做索引链接
- 新增记忆时：1) 详细内容写入 `./memory/<topic>.md`；2) 在下方"分类记忆索引"添加一行索引

## 分类记忆索引

详细参考文档存放在 `./memory/` 目录，按主题分类：

- [Linux 系统配置](memory/linux_system_config.md) — GRUB、BIOS、ACPI、Hibernate 休眠、ThinkPad
- [Linux 桌面与应用配置](memory/linux_desktop_config.md) — 图标、HiDPI、DPMS、Waydroid、省电、字体、输入法
