# POLYV iOS VOD SDK Demo

本项目详细演示了如何使用保利威视 iOS 点播 SDK。项目基于网校当前版本进行开发，实现了指定网校的视频播放与下载，同时可配置自己的保利威视点播账号，使用点播 SDK 播放与下载账号下的点播视频。

## 试用

[点击安装](https://www.pgyer.com/Li0i)，或扫描下方二维码使用 Safari 安装。

![](https://www.pgyer.com/app/qrcode/Li0i)

试用的内测 App 使用企业签名，若运行中遇到问题，可参见 [wiki-12.FAQ](https://github.com/polyv/polyv-ios-vod-sdk/wiki/12.FAQ)。

## 快速开始

1. `git clone https://github.com/polyv/polyv-ios-vod-sdk.git`
2. `pod install`

## 文档

详细文档请参见 [本项目 wiki](https://github.com/polyv/polyv-ios-vod-sdk/wiki)。

POLYV iOS VOD SDK [API 接口文档](https://polyv-repo.oss-cn-shenzhen.aliyuncs.com/ios/documents/vodsdk/2.20.1-231030/index.html)。

## 更新日志

POLYV iOS VOD SDK 更新日志可参见 [CHANGELOG](./CHANGELOG.md)。

## ATS

POLYV iOS VOD SDK 所有请求都使用 HTTPS 协议，已全面支持 ATS（App Transport Security）。

## iPhone X 适配

播放器及其 Demo 所有页面已针对 iPhone X 进行适配，若有在 iPhone X 显示不正常的 UI，欢迎 issue 本项目。

## 系统要求

本项目及其点播 SDK 最低支持兼容系统版本为 iOS 11。

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
