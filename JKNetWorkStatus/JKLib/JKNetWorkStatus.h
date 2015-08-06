//
//  JKNetWorkStatus.h
//  JKNetWorkStatus
//
//  Created by Jack on 15/8/6.
//  Copyright (c) 2015年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKReachability.h"
#import "CoreStatusMacor.h"

/**
 *  网络状态
 */
typedef enum{
    
    CoreNetWorkStatusNone=0,//无网络
    CoreNetWorkStatusWifi,
    CoreNetWorkStatusWWAN,//蜂窝
    CoreNetWorkStatus2G,
    CoreNetWorkStatus3G,
    CoreNetWorkStatus4G,
    CoreNetWorkStatusUnkhow // 未知
    
}CoreNetWorkStatus;

@class JKNetWorkStatus;


@protocol JKNetWorkStatusDelegate <NSObject>

//@property (nonatomic,assign) NetworkStatusJK currentStatus;

@optional

/** 网络状态变更 */
-(void)coreNetworkChangeNoti:(NSNotification *)noti;

@end



@interface JKNetWorkStatus : NSObject

JKSingletonH(JKNetWorkStatus)
/**
 *  获取当前网络状态
 *
 *  @return 网络状态枚举类型
 */
+(CoreNetWorkStatus)currentNetWorkStatus;

/** 获取当前网络状态：字符串 */
+(NSString *)currentNetWorkStatusString;

/** 开始网络监听 */
+(void)beginNotiNetwork:(id<JKNetWorkStatusDelegate>)listener;

/** 停止网络监听 */
+(void)endNotiNetwork:(id<JKNetWorkStatusDelegate>)listener;



/*
 *  新增API
 */
/** 是否是Wifi */
+(BOOL)isWifiEnable;

/** 是否有网络 */
+(BOOL)isNetworkEnable;








@end
