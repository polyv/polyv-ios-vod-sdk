# Changelog

本文档用于描述每个版本的更新、修改。本文档叙述了 `PolyvVodSDK` 项目的更新日志。

> 该项目已发布在 CocoaPods 中，查看各版本可使用 `pod trunk info PolyvVodSDK` 命令。

<!-- ## [Unreleased]
### Added
### Changed
### Removed
### Fixed -->

## [2.5.3] - 2018-12-17

### Added

- `PLVVodDownloadManager`，支持多任务下载功能，1～3 个
+ `@property (nonatomic, assign) NSUInteger maxRuningCount`   设置同时下载的最大任务数，默认为1
- `PLVVodDownloadManager (Database)`，新增下载管理分类，拓展sdk 数据库功能
+ `-createExtendTableWithClass`   创建扩展表
+ `-insertOrUpdateWithExtendInfo`  插入或更新一条记录
+ `-getExtendInfoWithClass:condition`  根据条件查询记录
+ `-getAllExtendInfoWithClass`  查询所有记录
+ `-deleteExtendInfoWithClass:condition` 根据条件删除一条记录
+ `-deleteAllExtendInfoWithClass`  删除所有记录
- `PLVVodExtendVideoInfo`，（Demo）数据库拓展表结构示例，具体参考demo
- `PLVVodDBManager`，（Demo）新增PLVVodDBManager 二次封装sdk 数据库操作api，方便应用处理，具体参考demo
- `PLVVodPlayerViewController`，增加seekType属性，实现精确seek功能
+ `@property (nonatomic, assign) PLVVodPlaySeekType seekType;`
- `PLVSubtitleManager`，（Demo）播放器支持顶部显示字幕功能，pod 'PLVSubtitle', '~> 0.1.0' 
+ `-managerWithSubtitle:lale:topLable:error`   支持顶部显示字幕初始化方法
- `PLVVodServiceUtil`，（Demo）添加批量获取视频播放次数接口 
+ `-requestPlayTimesWithVids`  根据vid数组批量获取播放次数

### Changed

-   Cocoapods 支持动态库方式集成sdk，解决与其他音视频sdk部分冲突问题,集成方式：
+ `pod 'PolyvVodSDK_Dylib'`  


### Fixed

- 答题正确，不能续播而是重新播放问题修复 （Demo）
- 音频模式下，从后台回到前台，播放动画停止问题修复 （Demo）
- 长按皮肤功能设置按钮，播放器皮肤再也无法显示问题修复 （Demo）
- 断点数据失效后，视频不能再次下载问题修复
- 播放器已经退出，部分场景下仍会中断第三方App后台播放问题修复

## [2.5.2] - 2018-11-08

### Added

- `PLVVodPlayerViewController`，支持URL播放视频，兼容第三方平台视频播放
    + `-setURL`   通过URL 播放/切换视频
- `PLVVodPlayerUtil`，新增播放器工具类，提供播放进度，播放进度时间戳获取方法
    + `-lastPositionWithVid`   通过vid获取上一次播放进度
    + `-lastPositionTimestampWithVid`  通过vid获取上一次播放进度时间戳
- `PLVVodPlayerViewController`，新增循环播放属性（暂不支持m3u8视频），适用短视频播放场景
    + `@property (nonatomic, assign) BOOL enablePlayRecycle;`
- `PLVVodErrorUtil`，Demo 中新增错误处理工具类，根据错误码返回错误提示，支持自定义错误提示
    + `-getErrorMsgWithCode`   根据错误码返回错误提示
- `PLVVodServiceUtil`，Demo 中新增业务工具类，提供相关拓展的API 接口
    + `-requestVideoListWithAccount`   根据子账户，视频分类id等参数，获取视频列表信息
    
### Changed
-  PLVVodVideo 模型title属性修改为可读写，用户可自定义设置title
- 播放器音量调节，可选择调节系统音量还是播放器音量，参见Demo  PLVVodSkinPlayerController 类中音量调节逻辑

### Fixed

- 1.0 升级到2.0，已缓存视频兼容问题修复
- 播放令牌接口，viewerId,viewerName 支持base64编码，修复参数含中文字符时获取token失败问题
- 同一播放器切换视频后，数据统计错误问题修复
- 非ViewDidLoad 函数中初始化播放器，iPad 上崩溃问题修复


## [2.5.1] - 2018-09-26

### Fixed

- 调用Api 进行码率切换，切换后视频会暂停播放问题修复
- 添加视频到下载队列，立即保存记录到数据库，解决退出app 后有时不能保存下载记录的问题


## [2.5.0] - 2018-09-17

### Added

- `PLVVodDownloadManager`，下载队列中添加指定视频的暂停/开始功能，用法参见demo
    + `-startDownloadWithVid`  开始下载指定视频
    + `-stopDownloadWithVid` 停止下载指定视频

- `PLVVodDownloadManager`，新增从数据库中获取缓存中/已缓存视频列表信息，用法参见demo
    + `-requstDownloadProcessingListWithCompletion`  从数据库中获取所有缓存中视频信息（准备缓存，缓存中，缓存失败 等等）
    + `-requestDownloadCompleteList` 从数据库获取所有已缓存成功视频信息

- `PLVVodDownloadManager`，新增单个视频的下载完成回调，用法参见demo
    + `@property (nonatomic, copy) void(^downloadCompleteBlock)(PLVVodDownloadInfo *info);`

- `PLVVodDownloadManager`，新增根据vid 获取下载信息方法
    + `-requestDownloadInfoWithVid `
    
- `PLVVodVideo`，新增videojson 获取方法，此方法自动更新保存videojson 到本地数据库，且优先返回本地数据
    + `-requestVideoPriorityCacheWithVid `  添加视频到下载队列，获取videojson 时优先使用该方法

- 增加视频详情数据库缓存功能

### Changed

- 下载页面改版，界面交互优化为缓存中/已缓存 列表
- 优化已缓存界面展示播放逻辑，先通过-localVideos 方法从本地目录获取已缓存视频列表基本信息，再通过-requestDownloadCompleteList 方法
获取已缓存视频列表详细信息，组合数据后分别用于本地视频播放与界面展示。详见demo。

### Fixed

- 恢复HLS 加密视频zip 下载方式
- mp4 / flv 等单文件视频下载，支持后台下载功能
- `PLVVodDownloadManager`  中 `-localVideos`  方法bug修复，过滤未缓存完成的HLS 视频
- 播放器Ipad 横竖屏适配
- 部分源文件视频播放失败修复
- 断网后再联网，下载状态不正确问题修复
- 提升下载功能的整体稳定性


## [2.4.1] - 2018-08-31

### Added

- 播放器支持默认音频播放功能

- `PLVVodPlayerViewController`，新增正常播放结束标志属性，用于判断播放器是正常播放结束，还是异常播放结束；
    + `@property (nonatomic, readonly) BOOL reachEndSuccess;`
- `PLVVodPlayerViewController`，新增播放恢复回调，播放异常结束后，该block每5s回调一次，在该block中可实现恢复播放逻辑;具体可参考PLVVodSkinPlayerController 文件中相关逻辑
   + `@property (nonatomic, copy) void (^playbackRecoveryHandle)(PLVVodPlayerViewController *player);`


### Fixed

- 码率切换，视频会重新播放 
- 视频播放结束，不能区分是正常结束，还是异常结束
- 同一个播放器播放不同视频，不能准确记录各个视频的历史播放位置
- 断网状态播放离线视频，视频总时长显示错误
- 播放器解析的视频时长与videojson的视频时长不一致，导致错误记录历史播放位置，再次播放视频总是从最后几秒开始播放


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
