# 桌面工作台 · Desktop Studio

**中文** | [English](README.en.md)

把 Windows 桌面工具放进一个小工作台：一键启动苹果风桌面、一键恢复 Windows，
集中管理 Dock、顶栏、应用分类和桌面小组件。

这是一个 **整合包与配置项目**。桌面能力来自 Seelen UI、Rainmeter 和 Monterey；
本项目提供原生管理 UI、启动/恢复脚本、柔白主题、高清适配及网易云桥接。
各项目保留原作者、许可证和独立设置，详见 [第三方项目说明](THIRD_PARTY_NOTICES.md)。

## 桌面效果

![4K 桌面实拍：柔白组件、完整顶栏和 Dock](docs/shots/desktop-4k.png)

当前实际桌面截图，原图 **3840 × 2160**；音乐卡片处于未播放状态。
示例壁纸、应用图标与个人应用排列不随整合包分发。

![应用分类面板，统一图标比例](docs/shots/app-categories.png)

分类预览与展开后的应用图标均使用正方形区域，保留图片原始比例。

## 原生工作台

![桌面工作台](docs/shots/workbench.png)

## 能做什么

| 功能 | 行为 |
| --- | --- |
| 一键切换 | 启动 Seelen UI 与小组件；恢复时退出它们并显示 Windows 原生任务栏和桌面图标 |
| 柔白小组件 | 天气、中文月历、音乐卡片，便签按需显示；保留适度透明和大圆角 |
| 高清适配 | Rainmeter 使用原生 DPI 绘制；默认方形约 294 × 294 像素，音乐约 612 × 294 像素 |
| 双屏 Dock | 两块屏幕共享固定项和运行应用列表 |
| 完整顶栏 | 天气、托盘、输入法、蓝牙、网络、音量、通知、快捷设置和日期时间 |
| 八个分类 | 在分类文件夹内放入快捷方式，点击“同步快捷方式”更新启动面板 |
| 网易云适配 | 封面、播放控制和卡片内同步滚动歌词；2／3／4 行、字号、偏移与显示开关可配置 |
| 备份 | 本地保存主题、布局和组件变量；整合包源码与本机数据分离 |

工作台是 **C# / WPF 原生程序**，关闭管理窗口后，桌面和小组件继续运行。

高清模式由每次启动时显式指定，不依赖仅在某个启动环境生效的兼容性设置。
天气直接更新数据；顶栏使用随包提供的兼容入口，避免天气刷新后系统按钮消失。

## 安装

需要 **Windows 11 x64、.NET Framework 4.8，以及 Seelen UI 所需的 WebView2**。
网易云音乐与 Wallpaper Engine 为可选外部软件，需自行安装。

1. 从 [Releases](https://github.com/Qi-95827/desktop-studio/releases) 下载
   `DesktopStudio-*-win-x64.zip`，完整解压。
2. 双击 `Install.cmd`。默认安装到 **`D:\Program Files (x86)\DesktopStudio`**。
   首次安装需要联网，从上游下载固定版本的三个组件并校验 SHA-256。
3. 如果 Seelen UI 已在运行，先退出它再安装。安装前会在本地备份现有配置；
   该预设会更新 Dock、顶栏和收藏分类。
4. 打开桌面上的“桌面工作台”，点击 **启动苹果风桌面**。

安装命令也可以指定目录；D 盘不存在时请换成自己的路径：

```powershell
.\scripts\Install.ps1 -InstallRoot 'D:\Program Files (x86)\DesktopStudio'
```

查看安装计划，不修改桌面：

```powershell
.\scripts\Install.ps1 -Plan
```

这是**首次联网安装的整合包**，不内置商业软件，也不镜像分发第三方安装程序。
版本、下载地址和校验值见 [dependencies.lock.json](dependencies.lock.json)。下载文件
缓存于安装目录的 `downloads`，后续安装会校验并复用。Seelen UI 的上游安装器和
系统运行时可能需要自己的安装权限或系统目录，D 盘设置不改变它们的系统要求。

## 日常使用

![小组件管理](docs/shots/widgets.png)

- **桌面总览**：启动 / 恢复桌面、打开各工具设置、恢复推荐布局、预览桌面。
- **小组件**：分别显示/隐藏天气、月历、音乐、便签，编辑便签内容。
- **工具与项目**：查看实际采用的上游项目，并打开各自的设置。
- **分类与备份**：管理快捷方式、同步分类、备份配置、编辑工具路径。

点击“启动苹果风桌面”会注册当前用户的开机启动项，并记住当前桌面模式。
以后登录 Windows 时自动恢复，无需手动打开工作台。点击“恢复 Windows”后，
下次启动会沿用 Windows 模式。可在 Windows 的“启动应用”里禁用“DesktopStudio”。

### 网易云音乐

1. 在网易云 **设置 → 系统 → 开启 SMTC**。
2. 安装器会尝试寻找常见路径；没有找到时，在工作台“分类与备份”中打开
   `config.json`，填写 `NetEaseExe`。
3. 播放一首歌，卡片会更新；桥接只读取 `cloudmusic.exe` 的媒体会话。

#### 卡片内同步歌词（可选）

在 **小组件 → 网易云音乐卡片 → 安装歌词适配** 安装适配层，完全退出并重新打开
网易云，再进入 **歌词设置** 启用。受保护的网易云安装目录需要 Windows 授权。
当前适配版本针对 **网易云 3.1.20–3.1.41 x64**；其他版本不会自动写入插件。

- 保留上方左封面、右侧歌名与播放控制；歌词在同一张柔白卡片下方显示。
- 可选 **2／3／4 行**、14–24 号字、±5 秒同步偏移和平滑滚动；关闭后恢复原高度。
- 当前行加深，相邻行淡化；跟随真实播放进度，支持暂停、切歌与跳转。
- **InfLink-rs** 提供歌曲 ID 和准确进度，**Lyricify Lyrics Helper** 获取及解析歌词。
  未收到有效进度时显示等待提示，不用系统时间猜测歌曲进度。
- 插件与缓存放在整合包 `Data/`，歌词只按歌曲请求并缓存在本机；不上传歌词、
  音乐、封面、账号或网易云登录数据。默认关闭歌词，用户按需安装适配并启用。

命令行可预览可选适配的安装计划：`scripts/Install-NetEaseLyrics.ps1 -Plan`。
适配只新增经过 SHA-256 校验的 `msimg32.dll` 加载器，不替换网易云原有可执行文件；
遇到已有的其他加载器会停止。版本与地址见 [lyrics-dependencies.lock.json](lyrics-dependencies.lock.json)。
升级网易云后，需重新核对插件兼容性；移除该加载器会恢复客户端原有加载方式。

专辑封面的清晰度取决于网易云通过系统接口提供的原图；
高清 DPI 适配不能把低分辨率封面变成真正的高清图片。

### 快捷方式分类

安装目录的 `Collections` 内有八个文件夹。把应用的 `.lnk` 或 `.url` **复制**到
对应文件夹，在工作台点击“同步快捷方式”，再重新打开分类面板。
整合包不包含作者电脑上的快捷方式，也不会搬走你的原文件。

### 天气与可选壁纸

默认城市为上海。`config.json` 可修改 `City`、`Latitude`、`Longitude`；更改后重新
应用配置以更新天气卡片。天气数据来自 [Open-Meteo](https://open-meteo.com/)。

如需 Wallpaper Engine 入口，填写 `WallpaperEngineExe`。整合包不更换现有壁纸，
不含任何创意工坊壁纸；`RestoreWallpaperEngine` 默认关闭。

## 文件与数据

| 目录 / 文件 | 内容 |
| --- | --- |
| `src/` | WPF 界面、媒体封面桥接源码、DPI 清单 |
| `scripts/` | 编译、安装、配置、切换、备份、快捷方式同步和媒体桥接 |
| `presets/SeelenUI/` | 原创主题、插件、完整顶栏布局 |
| `presets/Monterey/` | Monterey 衍生覆盖文件，保留 CC BY-NC-SA 4.0 |
| `runtime/Rainmeter/` | 安装后生成的便携运行器和皮肤，不进入 Git |
| `config.json` | 本机工具路径和偏好，不进入 Git |
| `Data/`、`Backups/`、`Collections/` | 本机状态、备份、个人快捷方式，不进入 Git |

Seelen UI 使用自己的用户配置目录。安装前的副本保存在整合包 `Backups` 中。
“恢复 Windows”切换桌面显示，不等于卸载软件或恢复安装前的 Seelen 配置。

## 从源码构建

```powershell
.\scripts\Verify.ps1
.\scripts\Build.ps1
.\Start.cmd
```

工作台使用 Windows 自带 .NET Framework x64 编译器；歌词桥接另需 .NET 6 SDK。
输出到 `bin/`；`scripts/Build-Lyrics.ps1 -SelfContained` 生成自带运行时的 x64 歌词进程，
Release 包无需用户额外安装 .NET 6。歌词库固定源码保存在 `third_party/`，保留 Apache-2.0。
源码目录不含第三方运行器，使用桌面功能前仍需执行安装。
`scripts/Package.ps1` 生成带预编译 UI 的 Release ZIP。

## 常见问题

- **Rainmeter 可以关吗？** 管理窗口可以关；退出后台程序会让小组件消失。
- **图标角标一直增长？** Seelen UI 会统计 Windows 通知中心里仍保留的应用通知；
  阅读聊天不一定清除这些系统通知。
- **两块屏幕的组件会自动复制吗？** Dock 和顶栏共享布局；Rainmeter 卡片是独立窗口，
  默认放在主屏，可以拖到另一块屏幕，不会自动生成两套。
- **恢复后文件还在吗？** 只切换桌面图标显示，原文件不移动、不删除。
- **替换整合包版本？** 先退出工作台并备份本机配置，再替换程序；不要把个人
  `Data`、`Backups` 或 `Collections` 上传到公开仓库。

## 致谢与许可

感谢 [Seelen UI](https://github.com/eythaann/Seelen-UI)、
[Rainmeter](https://github.com/rainmeter/rainmeter)、
[Monterey Rainmeter](https://github.com/creewick/MontereyRainmeter) 及其插件作者。
完整列表、版本、用途和许可见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

原创工作台与整合脚本采用 [MIT](LICENSE)。Monterey 衍生皮肤保持
**CC BY-NC-SA 4.0**，其非商业与相同方式共享要求不会因组合进本项目而消失。
