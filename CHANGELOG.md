# Changelog

本文档用于描述每个版本的更新、修改。本文档叙述了 `PolyvVodSDK` 项目的更新日志。

> 该项目已发布在 CocoaPods 中，查看各版本可使用 `pod trunk info PolyvVodSDK` 命令。

<!-- ## [Unreleased]
### Added
### Changed
### Removed
### Fixed -->


## [2.5.1] - 2018-09-01

### Added

- 播放器支持默认音频播放功能

- `PLVVodPlayerViewController`，新增正常播放结束标志属性，用于判断播放器是正常播放结束，还是异常播放结束
        +`@property (nonatomic, readonly) BOOL reachEndSuccess;`
- `PLVVodPlayerViewController`，新增播放恢复回调，播放异常结束后，该block每5s回调一次，在该block中可实现恢复播放逻辑;具体可参考PLVVodSkinPlayerController 文件中相关逻辑
        + `@property (nonatomic, copy) void (^playbackRecoveryHandle)(PLVVodPlayerViewController *player);`


### Fixed

- 码率切换，视频会重新播放 
- 视频播放结束，不能区分是正常结束，还是异常结束
- 同一个播放器播放不同视频，不能准确记录各个视频的历史播放位置
- 断网状态播放离线视频，视频总时长显示错误
- 播放器解析的视频时长与videojson的视频时长不一致，导致错误记录历史播放位置，再次播放视频总是从最后几秒开始播放


## [2.5.0] - 2018-08-19

### Added

- `PLVVodDownloadManager`，下载队列中添加指定视频的暂停/开始功能，用法参见demo
	+ `-startDownloadWithVid`  开始下载指定视频
	+ `-stopDownloadWithVid` 停止下载指定视频

- `PLVVodDownloadManager`，新增从数据库中获取缓存中/已缓存视频列表信息，用法参见demo
	+ `-requstDownloadProcessingListWithCompletion`  从数据库中获取所有缓存中视频信息（准备缓存，缓存中，缓存失败 等等）
	+ `-requestDownloadCompleteList` 从数据库获取所有已缓存成功视频信息

- `PLVVodDownloadManager`，新增单个视频的下载完成回调，用法参见demo
	+ `@property (nonatomic, copy) void(^downloadCompleteBlock)(PLVVodDownloadInfo *info);`


### Changed

- 下载页面改版，界面交互优化为缓存中/已缓存 列表
- 优化已缓存界面展示播放逻辑，先通过-localVideos 方法从本地目录获取已缓存视频列表基本信息，再通过-requestDownloadCompleteList 方法
获取已缓存视频列表详细信息，组合数据后分别用于本地视频播放与界面展示。详见demo。

### Fixed

- 恢复HLS 加密视频zip 下载方式
- mp4 / flv 等单文件视频下载，支持后台下载功能
- `PLVVodDownloadManager`  中 `-localVideos`  方法bug修复，过滤未缓存完成的HLS 视频
- 提升下载功能的整体稳定性



## [2.4.0] - 2018-07-16

### Added

- `PLVVodDownloadManager`，添加App 进入前台，后台状态时的方法，用于提升后台下载的稳定性；
+ `-applicationWillEnterForeground`  App 回到前台调用，具体参考AppDelegate 里面调用方式
+ `-applicationDidEnterBackground` App 切换到后台调用，具体参考AppDelegate 里面调用方式

### Fixed

- 优化下载逻辑，提升后台下载的稳定性

## [2.3.3] - 2018-06-26

### Added

- `PLVVodDownloadManager`，添加App即将终止运行时的调用方法，修改并保存视频下载状态，用于App下次启动时恢复视频下载状态；
        + `-applicationWillTerminate`

### Fixed

- 紧急修复视频下载过程中，App终止运行，再次启动App 后，下载列表视频状态不正确，且不能正常下载视频的问题
- 一般修复码率切换后，播放器倍速显示不匹配的问题


## [2.3.0] - 2018-06-08

### Added

- 增加音视频播放切换功能，具体用法参考 demo中 PLVVodSkinPlayerController 的例子

### Fixed

- 解决断网状态，不能播放本地已经下载视频的bug


## [2.2.0] - 2018-04-12

### Added

- `PLVVodDownloadManager`, 补充兼容 1.x.x 离线视频方法；
	+ `-compatibleWithPreviousVideos`

## [2.1.0] - 2018-03-27

### Added

- `PLVVodPlayerViewController`，添加是否就绪播放回调；
	+ `@property (nonatomic, copy) void (^preparedToPlayHandler)(PLVVodPlayerViewController *player);`
- `PLVVodPlayerViewController`，添加播放状态回调；
	+ `@property (nonatomic, copy) void (^playbackStateHandler)(PLVVodPlayerViewController *player);`
- `PLVVodPlayerViewController`，添加加载状态回调；
	+ `@property (nonatomic, copy) void (^loadStateHandler)(PLVVodPlayerViewController *player);`
- `PLVVodPlayerViewController`，添加播放结束回调；
	+ `@property (nonatomic, copy) void (^reachEndHandler)(PLVVodPlayerViewController *player);`

## [2.0.0] - 2018-03-21

### Changed

- 优化接口文档注释；
- `PLVVodPlayerViewController` 中 `autoContinue` 命名更改为更为准确的 `rememberLastPosition`；

## [2.0.0] - 2018-03-19

### Changed

- 优化接口文档注释，为类、枚举、常量添加文档注释；

## [2.0.0] - 2018-03-16

### Added

- 问答增加错误注解、正确注解属性与逻辑；

### Changed

- 优化切换视频时更新播放器状态值逻辑；
- 优化接口文档注释，添加默认值的描述；
- 优化自动播放逻辑；
- 更新版本号；

## [0.0.5] - 2018-03-14

### Added

- 添加错误类型“视频与账号不匹配”；
- 添加网络监测功能；
- 添加错误类型“网络不可达”；
- 为 viewlog、Qos 和错误收集建立缓存队列；

### Changed

- 优化播放器界面布局；
- 优化广告播放器布局；
- 优化广告播放逻辑；
- 优化片头播放逻辑；
- 优化播放器事件回调；
- 优化下载管理器接口；
	+ `- (void)requestDownloadInfosWithCompletion:(void (^)(NSMutableArray<PLVVodDownloadInfo *> *downloadInfos))completion;` -> `- (void)requestDownloadInfosWithCompletion:(void (^)(NSArray<PLVVodDownloadInfo *> *downloadInfos))completion;`
- 优化自动续播逻辑；
- 优化广告状态回调；
- 优化无广告时的 UI；
- 优化 `PLVVodVideo` 接口；
- 添加 `PLVVodVideo` 对象描述；
- `PLVVodAd` 实现 `NSStringFromPLVVodAdType`、`NSStringFromPLVVodAdLocation` 函数；
- 优化广告匹配逻辑，实现每种广告按照其所在的分类中回溯寻找、设置广告；
- 优化播放器跑马灯视图层级；
- 优化网络请求错误日志；
- 优化本地视频文件大小的获取；
- 优化移除下载任务逻辑；
- `PLVVodDownloadManager`，`enableBackgroundDownload` 在 iOS 8 以上默认为 YES；
- 优化 `PLVVodVideo` 的 `-available` 判断逻辑；
- 优化 `PLVVodDownloadManager` 无法创建下载器时的错误回调；
- 优化 httpDNS 逻辑；
- 优化代码文档注释；

### Removed

- `PLVVodPlayerViewController` 去除冗余属性：`enableSrt`、`srtKey`；

### Fixed

- 修复播放片头、广告内存不能释放问题；
- 修复播放器由于子类属性重名引起的定时器不能销毁释放问题；
- 修复直播转存视频类型判断错误导致的下载失败问题；
- 修复广告时长逻辑；
- 修复音量与播放器值不同步问题；
- 修复时间显示格式；
- 修复 `-requestDownloadInfosWithCompletion:` 死循环崩溃问题；
