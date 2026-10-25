# 第三方项目与许可 / Third-party projects and licenses

Desktop Studio（桌面工作台）是本地整合与配置项目。工作台 UI、脚本与原作者的
桌面引擎、皮肤、插件是不同作品，保留各自作者、商标和许可证。

| 项目 / Project | 固定版本 / Version | 用途 / Role | 许可证 / License |
| --- | --- | --- | --- |
| [Seelen UI](https://github.com/eythaann/Seelen-UI/tree/v2.8.10) | 2.8.10 | Dock、顶栏、系统托盘、应用分类 / Desktop shell | [AGPL-3.0](https://github.com/eythaann/Seelen-UI/blob/v2.8.10/LICENSE) |
| [Rainmeter](https://github.com/rainmeter/rainmeter/tree/v4.5.28.3936) | 4.5.28.3936 | 小组件运行器 / Widget runtime | [GPL-2.0](https://github.com/rainmeter/rainmeter/blob/v4.5.28.3936/LICENSE) |
| [Monterey Rainmeter](https://github.com/creewick/MontereyRainmeter/tree/v1.0.2) | 1.0.2 | 天气、月历、音乐、便签 / Widget skins | [CC BY-NC-SA 4.0](licenses/Monterey-CC-BY-NC-SA-4.0.txt) |
| [Lyricify Lyrics Helper](https://github.com/WXRIW/Lyricify-Lyrics-Helper/tree/3fc579b029c24a1f54ebb2fd002ee3624c85c7e7) | 0.2.1 / 3fc579b | 网易云歌词获取与 LRC 解析 / Lyrics provider and parser | [Apache-2.0](licenses/Lyricify-Apache-2.0.txt) |
| [BetterNCM](https://github.com/std-microblock/chromatic/tree/1.3.4) | 1.3.4 x64 | 可选网易云插件加载器 / Optional plugin loader | [GPL-3.0](licenses/BetterNCM-GPL-3.0.txt) |
| [InfLink-rs](https://github.com/apoint123/inflink-rs/tree/v3.4.0) | 3.4.0 | 歌曲 ID、播放进度和控制 / SMTC timeline and track identity | [GPL-3.0](licenses/InfLink-rs-GPL-3.0.txt) |
| [Open-Meteo](https://open-meteo.com/) | 在线服务 / Service | 天气数据 / Weather data | [数据署名与 API 条款 / Data attribution and API terms](https://open-meteo.com/en/terms) |

`dependencies.lock.json` 记录发布者原始下载地址、版本和 SHA-256。公开发布包不
重新打包第三方安装程序；首次安装从原发布者下载并校验。第三方加载器与插件按需从原发布者下载，不内置网易云客户端。

## Monterey 衍生皮肤

`presets/Monterey/` 基于 **creewick/MontereyRainmeter v1.0.2**。该目录保留
**CC BY-NC-SA 4.0**，不能把它与工作台自己的 MIT 许可混为一谈。

修改内容：柔白微透明圆角、紧凑尺寸、高清 DPI 适配所需尺寸、中文天气与日历，
以及从原生 Unicode 配置读取网易云歌名、歌手、封面和状态。文件清单见
[CHANGES.md](presets/Monterey/CHANGES.md)。作者署名与完整许可证随包保留。

## Seelen 顶栏兼容入口

`presets/SeelenUI/plugins/stable-*/metadata.json` 的作用逻辑来自
Seelen UI v2.8.10 的 `src/static/widgets/*/toolbar-plugin.yml` 及其引用的模板。
这些衍生文件保留 **AGPL-3.0**（[完整许可证](licenses/Seelen-AGPL-3.0.txt)）。
修改为独立插件的资源 ID、显示名及说明，使入口不依赖在插件热重载时可能被移除的
内嵌插件注册项。对应源文件随仓库提供；上游作者为 Seelen UI contributors。

## 原皮肤附带插件

Monterey 原始安装包还附带以下第三方插件；它们由原始下载包提供，未纳入本仓库的
原生 UI 或重新授权。Rainmeter 自带插件的许可随 Rainmeter 分发。

- [MediaPlayer — i2002](https://github.com/i2002/RainmeterMediaPlayer)：原音乐皮肤插件；本项目的网易云卡片改用自己的 SMTC 桥接。
- [Chameleon — socks-the-fox](https://github.com/socks-the-fox/Chameleon)：皮肤配色相关功能。
- [AppVolume — khanhas](https://github.com/khanhas/AppVolumePlugin)：上游音量组件。
- [ConfigActive — jsmorley](https://forum.rainmeter.net/viewtopic.php?t=28720)：皮肤激活状态。
- [FrostedGlass](https://github.com/Meti0X7CB/FrostedGlass)：上游模糊主题插件；当前柔白预设不启用它。
- MouseXY、TrayIcon：保留原安装包及上游提供的署名、许可与使用说明。

## 外部软件，不随包分发

- **网易云音乐 / NetEase Cloud Music**：用户自行安装；本项目只读取和控制 Windows
  SMTC 媒体会话；可选歌词安装向客户端目录新增 BetterNCM 加载器，不替换原有
  可执行文件。不分发客户端、音乐、歌词或封面缓存。
- **Wallpaper Engine**：可选、需用户自行购买/安装；只提供启动入口。不包含其
  程序、Steam 创意工坊内容或本机壁纸。
- **Windows / .NET / WebView2**：系统及各自运行时组件按 Microsoft 原有条款提供。

## English summary

This is an integration bundle, not a new desktop engine or a relicensing of upstream
projects. The original launcher, scripts and Seelen theme are MIT. Monterey-derived
overlays remain CC BY-NC-SA 4.0, with attribution and a change list included.
Seelen-derived `stable-*` toolbar compatibility plugins retain AGPL-3.0.
Installers are downloaded unchanged from upstream publishers with pinned SHA-256
verification. Seelen UI, Rainmeter, bundled skin plugins and weather data keep their
respective licenses. Proprietary clients, media, wallpapers and personal settings
are not redistributed.

## 歌词复用 / Lyrics reuse

`third_party/Lyricify-Lyrics-Helper` 基于上游 3fc579b 的源码快照（不含 demo），
保留 Apache-2.0 和作者署名。使用其网易云 provider 与 LRC parser，没有另写歌词引擎。
本地构建移除了未用到的 Microsoft International Pack `CHTCHSConv` 二进制依赖；
两个可选繁简转换方法改用库内已有字典，provider、parser 与歌词模型保持上游实现。
剩余 NuGet 依赖为 Newtonsoft.Json 13.0.3、SharpZipLib 1.4.2（MIT），许可随包保留。Release 内的 .NET 6 自带运行时
保留 Microsoft 的 `LICENSE.txt` 与 `ThirdPartyNotices.txt`。

InfLink-rs 与 BetterNCM 是独立运行的 GPL-3.0 组件；本项目通过 Windows SMTC 协议
通信，不复制或重新授权其实现。对应固定 tag 的完整源代码链接见上表。
Monterey 音乐卡片的新增布局和 Lua 数值动画随衍生皮肤保持 CC BY-NC-SA 4.0。

The pinned Lyricify library is reused under Apache-2.0. Optional GPL-3.0
BetterNCM/InfLink-rs are downloaded separately and communicate through Windows SMTC.
Only local adapter code and UI are part of the original launcher; upstream licenses
remain in force. Lyrics, music, artwork caches and NetEase account data are excluded.
