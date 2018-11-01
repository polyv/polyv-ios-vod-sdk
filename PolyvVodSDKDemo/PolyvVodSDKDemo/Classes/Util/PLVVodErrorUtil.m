//
//  PLVVodUtil.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodErrorUtil.h"

@implementation PLVVodErrorUtil

+ (NSString *)getErrorMsgWithCode:(PLVVodErrorCode )errorCod{
    NSString *errHelp = nil;
    switch (errorCod) {
        case account_video_illegal:{
            errHelp = @"视频或账号不合法，请向管理员反馈";
        }break;
        case account_flow_out:{
            errHelp = @"流量超标，请向管理员反馈";
        }break;
        case account_time_out:{
            errHelp = @"账号过期，请向管理员反馈";
        }break;
        case video_unmatch_account: {
            errHelp = @"视频与账号不匹配，请向管理员反馈";
        }break;
        case account_encode_key_illegal:{
            errHelp = @"播放秘钥不合法，请向管理员反馈";
        }break;
        case account_encode_iv_illegal:{
            errHelp = @"播放加密向量不合法，请向管理员反馈";
        }break;
        case video_status_illegal:{
            errHelp = @"视频状态不合法，请向管理员反馈";
        }break;
        case playback_token_fetch_error:{
            errHelp = @"播放令牌请求失败,请尝试重新播放，或向管理员反馈";
        }break;
        case video_type_unknown:{
            errHelp = @"视频播放参数类型错误，请尝试重新播放，或向管理员反馈";
        }break;
        case video_not_found:{
            errHelp = @"无法找到视频，请尝试重新播放/下载，或向管理员反馈";
        }break;
        case teaser_type_illegal:{
            errHelp = @"不支持的片头视频格式，请向管理员反馈";
        }break;
        case playback_duration_illegal:{
            errHelp = @"视频时长错误，请向管理员反馈";
        }break;
        case ad_type_illegal:{
            errHelp = @"广告类型不支持，请向管理员反馈";
        }break;
        case downloader_create_error:{
            errHelp = @"下载对象创建失败，请尝试重新下载，或向管理员反馈";
        }break;
        case download_task_create_error:{
            errHelp = @"下载任务创建失败，请尝试重新下载，或向管理员反馈";
        }break;
        case download_error:{
            errHelp = @"下载失败，请尝试重新下载，或向管理员反馈";
        }break;
        case m3u8_write_error:{
            errHelp = @"m3u8文件写入失败，请尝试重新下载，或向管理员反馈";
        }break;
        case key_write_error:{
            errHelp = @"key文件写入失败，请尝试重新下载，或向管理员反馈";
        }break;
        case ts_path_fix_error:{
            errHelp = @"m3u8文件路径修复失败，请尝试重新下载，或向管理员反馈";
        }break;
        case unzip_error:{
            errHelp = @"下载文件解压失败，请尝试重新下载，或向管理员反馈";
        }break;
        case download_task_not_found:{
            errHelp = @"下载任务丢失，请尝试重新下载，或向管理员反馈";
        }break;
            
        case argument_illegal:{
            errHelp = @"传入参数错误，请向管理员反馈";
        }break;
        case download_dir_not_found:{
            errHelp = @"下载目录不存在，请向管理员反馈";
        }break;
        case target_file_is_dir:{
            errHelp = @"无法检索文件，目标存在同名目录,请向管理员反馈";
        }break;
        case key_fetch_error:{
            errHelp = @"播放秘钥请求失败,请尝试重新下载，或向管理员反馈";
        }break;
        case m3u8_fetch_error:{
            errHelp = @"m3u8文件请求失败,请尝试重新下载，或向管理员反馈";
        }break;
        case filename_not_found:{
            errHelp = @"获取下载文件名失败，请尝试重新下载，或向管理员反馈";
        }break;
        case ts_not_found:{
            errHelp = @"获取ts切片索引失败，请尝试重新下载，或向管理员反馈";
        }break;
        case local_file_unaccessible:{
            errHelp = @"本地资源无法访问，请向管理员反馈";
        }break;
        case local_key_illegal:{
            errHelp = @"本地视频播放秘钥错误，请删除视频并重新下载，或向管理员反馈";
        }break;
        case hls_dir_not_found:{
            errHelp = @"HLS 视频目录索引失败，请向管理员反馈";
        }break;
        case video_remove_error:{
            errHelp = @"视频文件移除失败，请重新移除，或向管理员反馈";
        }break;
        case file_move_error:{
            errHelp = @"文件移动错误，请向管理员反馈";
        }break;
        case network_unreachable:{
            errHelp = @"请检查网络连接设置，或向管理员返反馈";
        }break;
        case network_error:{
            errHelp = @"请检查网络连接设置，或向管理员返反馈";
        }break;
        case server_error:{
            errHelp = @"服务器响应错误，请向管理员返反馈";
        }break;
        case fetch_error:{
            errHelp = @"网络请求错误，请稍后重试，或向管理员反馈";
        }break;
        case json_read_error:{
            errHelp = @"JSON 解析错误，请稍后再试，或向管理员反馈";
        }break;
        case video_not_support_play_audio:{
            errHelp = @"当前视频不支持音频播放模式，请向管理员反馈";
        }break;
            
        default:
            break;
    }
            
    return errHelp;
}


@end
