//
//  PLVVodUtil.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodErrorUtil.h"

@implementation PLVVodErrorUtil

+ (NSDictionary *)errorDescriptionDict {
    NSDictionary *errorDict =
  @{
    @(account_video_illegal):@"视频或账号不合法，请向管理员反馈",
    @(account_flow_out):@"流量超标，请向管理员反馈",
    @(account_time_out):@"账号过期，请向管理员反馈",
    @(video_unmatch_account):@"视频与账号不匹配，请向管理员反馈",
    @(account_encode_key_illegal):@"播放秘钥不合法，请向管理员反馈",
    @(account_encode_iv_illegal):@"播放加密向量不合法，请向管理员反馈",
    @(video_status_illegal):@"视频状态不合法，请向管理员反馈",
    @(playback_token_fetch_error):@"播放令牌请求失败,请尝试重新播放，或向管理员反馈",
    @(video_type_unknown):@"视频播放参数类型错误，请尝试重新播放，或向管理员反馈",
    @(video_not_found):@"无法找到视频，请尝试重新播放/下载，或向管理员反馈",
    @(teaser_type_illegal):@"不支持的片头视频格式，请向管理员反馈",
    @(playback_duration_illegal):@"视频时长错误，请向管理员反馈",
    @(ad_type_illegal):@"广告类型不支持，请向管理员反馈",
    @(downloader_create_error):@"下载对象创建失败，请尝试重新下载，或向管理员反馈",
    @(download_task_create_error):@"下载任务创建失败，请尝试重新下载，或向管理员反馈",
    @(download_error):@"下载失败，请尝试重新下载，或向管理员反馈",
    @(m3u8_write_error):@"m3u8文件写入失败，请尝试重新下载，或向管理员反馈",
    @(key_write_error):@"key文件写入失败，请尝试重新下载，或向管理员反馈",
    @(ts_path_fix_error):@"m3u8文件路径修复失败，请尝试重新下载，或向管理员反馈",
    @(unzip_error):@"下载文件解压失败，请尝试重新下载，或向管理员反馈",
    @(download_task_not_found):@"下载任务丢失，请尝试重新下载，或向管理员反馈",
    @(argument_illegal):@"传入参数错误，请向管理员反馈",
    @(download_dir_not_found):@"下载目录不存在，请向管理员反馈",
    @(target_file_is_dir):@"无法检索文件，目标存在同名目录,请向管理员反馈",
    @(key_fetch_error):@"播放秘钥请求失败,请尝试重新下载，或向管理员反馈",
    @(m3u8_fetch_error):@"m3u8文件请求失败,请尝试重新下载，或向管理员反馈",
    @(filename_not_found):@"获取下载文件名失败，请尝试重新下载，或向管理员反馈",
    @(ts_not_found):@"获取ts切片索引失败，请尝试重新下载，或向管理员反馈",
    @(local_file_unaccessible):@"本地资源无法访问，请向管理员反馈",
    @(local_key_illegal):@"本地视频播放秘钥错误，请删除视频并重新下载，或向管理员反馈",
    @(hls_dir_not_found):@"HLS 视频目录索引失败，请向管理员反馈",
    @(video_remove_error):@"视频文件移除失败，请重新移除，或向管理员反馈",
    @(file_move_error):@"文件移动错误，请向管理员反馈",
    @(network_unreachable):@"请检查网络连接设置，或向管理员返反馈",
    @(network_error):@"请检查网络连接设置，或向管理员返反馈",
    @(server_error):@"服务器响应错误，请向管理员返反馈",
    @(fetch_error):@"网络请求错误，请稍后重试，或向管理员反馈",
    @(json_read_error):@"JSON 解析错误，请稍后再试，或向管理员反馈",
    @(video_not_support_play_audio):@"当前视频不支持音频播放模式，请向管理员反馈"
    };
    return errorDict;
}

+ (NSString *)getErrorMsgWithCode:(PLVVodErrorCode )errorCod{
    NSDictionary *errorDict = [self errorDescriptionDict];
    return [errorDict objectForKey:@(errorCod)] ?: @"";
}


@end
