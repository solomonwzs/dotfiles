# Wine 字体问题处理

Wine 默认不带中日韩字体，中文/日文/韩文程序常显示方块（豆腐块 □□□）或乱码。
用 `winetricks` 安装字体组件解决。

## 三条核心命令

```sh
winetricks cjkfonts      # 安装真实的开源 CJK（中日韩）字体，提供东亚字形
winetricks corefonts     # 安装微软核心英文字体（Arial/Times New Roman/Courier New 等）
winetricks fakechinese   # 把中文字体名（宋体/黑体/微软雅黑）映射到已装的开源字体
```

| 命令 | 做什么 | 解决的问题 |
|------|--------|-----------|
| `cjkfonts` | 装真实的开源 CJK 字体 | 提供中日韩字形 |
| `corefonts` | 装微软核心英文字体 | 西文排版正常 |
| `fakechinese` | 把中文字体名映射到已装字体（注册表 FontSubstitutes） | 程序指名要"宋体/雅黑"时有替身 |

## 关系与用法

- `cjkfonts` 提供字形 → `fakechinese` 让程序按名（如"微软雅黑"）能找到替身字体。
- 两者配合基本解决 Wine 中文程序"显示方块/乱码"问题。
- `corefonts` 补齐英文界面的字体需求。
- `fakechinese` 不安装新字体，只是把版权字体名通过注册表 FontSubstitutes 重定向到免费字体。

## 真实微软字体

如需"真·微软雅黑/宋体"，需从 Windows 拷贝字体或安装对应真实字体包（涉及版权）。
