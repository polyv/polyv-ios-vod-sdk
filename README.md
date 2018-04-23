# POLYV iOS VOD SDK Demo

本项目详细演示了如何使用保利威视 iOS 点播 SDK。项目基于网校当前版本进行开发，实现了指定网校的视频播放与下载，同时可配置自己的保利威视点播账号，使用点播 SDK 播放与下载账号下的点播视频。

## 试用

[点击安装](https://www.pgyer.com/Qtuw)，或扫描下方二维码使用 Safari 安装。

![](https://www.pgyer.com/app/qrcode/Qtuw)

安装密码：polyv

试用的内测 App 使用企业签名，若运行中遇到问题，可参见 [在 iOS 9 及以上版本中运行企业版应用](https://github.com/polyv/polyv-ios-vod-sdk/wiki/RunEnterpriseApp)。

## 系统要求

- 本项目及其点播 SDK 最低支持兼容系统版本为 iOS 8。
- 本地环境需安装 CocoaPods，可参看[官方指导](https://guides.cocoapods.org/)。

## 快速开始

1. 下载 Demo 代码 `git clone https://github.com/polyv/polyv-ios-vod-sdk.git` 
2. 在终端工具下进入 PolyvVodSDKDemo 文件夹，`cd $路径/PolyvVodSDKDemo`
3. 下载 pods 依赖库，`pod install` 或 `pod update`（首次建议使用pod update命令）

## 文档

详细文档请参见 [本项目 wiki](https://github.com/polyv/polyv-ios-vod-sdk/wiki)。

点播 SDK 2.0 解决 1.0 的问题与优化，参见 [1.x-2.x 升级与优化](https://github.com/polyv/polyv-ios-vod-sdk/wiki/Improvement)。

POLYV iOS VOD SDK 各版本接口文档，可参见 [各版本 API 文档](https://github.com/polyv/polyv-ios-vod-sdk/wiki/API)。

## 更新日志

POLYV iOS VOD SDK 更新日志可参见 [CHANGELOG](./CHANGELOG.md)。

## ATS

POLYV iOS VOD SDK 所有请求都使用 HTTPS 协议，已全面支持 ATS（App Transport Security）。

## iPhone X 适配

播放器及其 Demo 所有页面已针对 iPhone X 进行适配，若有在 iPhone X 显示不正常的 UI，欢迎 issue 本项目。

## 部分逻辑说明

- 视频下载记录会记录到本地数据库，但仅在视频开始下载后才入库。
- 视频进度跳转，若跳转的不是关键帧则会往回跳到附近的关键帧。
- 记忆播放位置：
	- 记忆播放位置功能需在设置 video 对象之前设置。
	- 记忆播放位置开启后，在播放中途退出（包括中途出错退出）都会记录播放位置，下次进入播放器，会从该播放位置继续播放。
	- 播放结束后，会清除本视频记录的播放位置。
- 队列下载
	+ 目前实现的队列只支持单个视频队列下载，加入视频的队列只有第一个视频在下载，第一个视频下载后，下载后面的视频，以此类推。
	+ 队列的顺序由加入队列的顺序决定。

## 协议

本项目使用 Apache-2.0 许可证，详情见 [LICENSE](./LICENSE) 文件。
