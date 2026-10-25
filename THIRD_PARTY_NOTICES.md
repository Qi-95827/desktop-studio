# 第三方项目与许可 / Third-party projects and licenses

Desktop Studio（桌面工作台）是本地整合与配置项目。工作台 UI、脚本与原作者的
桌面引擎、皮肤、插件是不同作品，保留各自作者、商标和许可证。

| 项目 / Project | 固定版本 / Version | 用途 / Role | 许可证 / License |
| --- | --- | --- | --- |
| [Seelen UI](https://github.com/eythaann/Seelen-UI/tree/v2.8.10) | 2.8.10 | Dock、顶栏、系统托盘、应用分类 / Desktop shell | [AGPL-3.0](https://github.com/eythaann/Seelen-UI/blob/v2.8.10/LICENSE) |
| [Rainmeter](https://github.com/rainmeter/rainmeter/tree/v4.5.28.3936) | 4.5.28.3936 | 小组件运行器 / Widget runtime | [GPL-2.0](https://github.com/rainmeter/rainmeter/blob/v4.5.28.3936/LICENSE) |
| [Monterey Rainmeter](https://github.com/creewick/MontereyRainmeter/tree/v1.0.2) | 1.0.2 | 天气、月历、音乐、便签 / Widget skins | [CC BY-NC-SA 4.0](licenses/Monterey-CC-BY-NC-SA-4.0.txt) |
| [Open-Meteo](https://open-meteo.com/) | 在线服务 / Service | 天气数据 / Weather data | [数据署名与 API 条款 / Data attribution and API terms](https://open-meteo.com/en/terms) |

`dependencies.lock.json` 记录发布者原始下载地址、版本和 SHA-256。公开发布包不
重新打包第三方安装程序；首次安装从原发布者下载并校验。未修改上游程序文件。

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
  SMTC 媒体会话，不修改客户端文件，不分发音乐或歌词。
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
