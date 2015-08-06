//
//  JKNetWorkStatus.m
//  JKNetWorkStatus
//
//  Created by Jack on 15/8/6.
//  Copyright (c) 2015年 Jack. All rights reserved.
//

#import "JKNetWorkStatus.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>



static NSString *const JKCoreStatusChangedNoti = @"CoreStatusChangedNoti";


@interface JKNetWorkStatus ()


/** 2G数组 */
@property (nonatomic,strong) NSArray *technology2GArray;

/** 3G数组 */
@property (nonatomic,strong) NSArray *technology3GArray;

/** 4G数组 */
@property (nonatomic,strong) NSArray *technology4GArray;

/** 网络状态中文数组 */
@property (nonatomic,strong) NSArray *coreNetworkStatusStringArray;

@property (nonatomic,strong) JKReachability *reachability;

@property (nonatomic,strong) CTTelephonyNetworkInfo *telephonyNetworkInfo;

@property (nonatomic,copy) NSString *currentRaioAccess;

/** 是否正在监听 */
@property (nonatomic,assign) BOOL isNoti;



@end

@implementation JKNetWorkStatus
JKSingletonM(JKNetWorkStatus)



+(void)initialize{
    
    JKNetWorkStatus *status = [JKNetWorkStatus sharedJKNetWorkStatus];
    status.telephonyNetworkInfo =  [[CTTelephonyNetworkInfo alloc] init];
}




/** 获取当前网络状态：枚举 */
+(CoreNetWorkStatus)currentNetWorkStatus{
    
    JKNetWorkStatus *status = [JKNetWorkStatus sharedJKNetWorkStatus];
    
    return [status statusWithRadioAccessTechnology];
}


/** 获取当前网络状态：字符串 */
+(NSString *)currentNetWorkStatusString{
    
    JKNetWorkStatus *status = [JKNetWorkStatus sharedJKNetWorkStatus];
    
    return status.coreNetworkStatusStringArray[[self currentNetWorkStatus]];
}

-(JKReachability *)reachability{
    
    if(_reachability == nil){
        
        _reachability = [JKReachability reachabilityForInternetConnection];
    }
    
    return _reachability;
}


-(CTTelephonyNetworkInfo *)telephonyNetworkInfo{
    
    if(_telephonyNetworkInfo == nil){
        
        _telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        
    }
    
    return _telephonyNetworkInfo;
}


-(NSString *)currentRaioAccess{
    
    if(_currentRaioAccess == nil){
        
        _currentRaioAccess = self.telephonyNetworkInfo.currentRadioAccessTechnology;
    }
    
    return _currentRaioAccess;
}


/** 开始网络监听 */
+(void)beginNotiNetwork:(id<JKNetWorkStatusDelegate>)listener{
    
    JKNetWorkStatus *status = [JKNetWorkStatus sharedJKNetWorkStatus];
    
    if(status.isNoti){
        
        NSLog(@"CoreStatus已经处于监听中，请检查其他页面是否关闭监听！");
        
        [self endNotiNetwork:(id<JKNetWorkStatusDelegate>)listener];
    }
    
    //注册监听
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:@selector(coreNetworkChangeNoti:) name:JKCoreStatusChangedNoti object:status];
    [[NSNotificationCenter defaultCenter] addObserver:status selector:@selector(coreNetWorkStatusChanged:) name:JKReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:status selector:@selector(coreNetWorkStatusChanged:) name:CTRadioAccessTechnologyDidChangeNotification object:nil];
    
    [status.reachability startNotifier];
    
    //标记
    status.isNoti = YES;
    
    
}







/** 停止网络监听 */
+(void)endNotiNetwork:(id<JKNetWorkStatusDelegate>)listener{
    
    JKNetWorkStatus *status = [JKNetWorkStatus sharedJKNetWorkStatus];
    
    if(!status.isNoti){
        
        NSLog(@"CoreStatus监听已经被关闭"); return;
    }
    
    //解除监听
    [[NSNotificationCenter defaultCenter] removeObserver:status name:JKReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:status name:CTRadioAccessTechnologyDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:listener name:JKCoreStatusChangedNoti object:status];
    
    //标记
    status.isNoti = NO;
    
    
}







- (void)coreNetWorkStatusChanged:(NSNotification *)notification
{
    //发送通知
    
    if (notification.name == CTRadioAccessTechnologyDidChangeNotification &&
        notification.object != nil) {
        
        self.currentRaioAccess = self.telephonyNetworkInfo.currentRadioAccessTechnology;
    }
    
    //再次发出通知
    NSDictionary *userInfo = @{@"currentStatusEnum":@([JKNetWorkStatus currentNetWorkStatus]),@"currentStatusString":[JKNetWorkStatus currentNetWorkStatusString]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JKCoreStatusChangedNoti object:self userInfo:userInfo];
}





- (CoreNetWorkStatus)statusWithRadioAccessTechnology{
    
    CoreNetWorkStatus status = (CoreNetWorkStatus)[self.reachability currentReachabilityStatus];
    
    NSString *technology = self.currentRaioAccess;
    
    if (status == CoreNetWorkStatusWWAN &&
        technology != nil) {
        
        if ([self.technology2GArray containsObject:technology]){
            
            status = CoreNetWorkStatus2G;
            
        }else if ([self.technology3GArray containsObject:technology])
            
            status = CoreNetWorkStatus3G;
        
        else if ([self.technology4GArray containsObject:technology]){
            status = CoreNetWorkStatus4G;
        }
        
    }
    
    return status;
}

/*
 *  懒加载
 */
/** 2G数组 */
-(NSArray *)technology2GArray{
    
    if(_technology2GArray == nil){
        
        _technology2GArray = @[CTRadioAccessTechnologyEdge,CTRadioAccessTechnologyGPRS];
    }
    
    return _technology2GArray;
}


/** 3G数组 */
-(NSArray *)technology3GArray{
    
    if(_technology3GArray == nil){
        
        _technology3GArray = @[CTRadioAccessTechnologyHSDPA,
                               CTRadioAccessTechnologyWCDMA,
                               CTRadioAccessTechnologyHSUPA,
                               CTRadioAccessTechnologyCDMA1x,
                               CTRadioAccessTechnologyCDMAEVDORev0,
                               CTRadioAccessTechnologyCDMAEVDORevA,
                               CTRadioAccessTechnologyCDMAEVDORevB,
                               CTRadioAccessTechnologyeHRPD];
    }
    
    return _technology3GArray;
}

/** 4G数组 */
-(NSArray *)technology4GArray{
    
    if(_technology4GArray == nil){
        
        _technology4GArray = @[CTRadioAccessTechnologyLTE];
    }
    
    return _technology4GArray;
}

/** 网络状态中文数组 */
-(NSArray *)coreNetworkStatusStringArray{
    
    if(_coreNetworkStatusStringArray == nil){
        
        _coreNetworkStatusStringArray = @[@"无网络",@"Wifi",@"蜂窝网络",@"2G",@"3G",@"4G",@"未知网络"];
    }
    
    return _coreNetworkStatusStringArray;
}







/** 是否是Wifi */
+(BOOL)isWifiEnable{
    
    return [self currentNetWorkStatus] == CoreNetWorkStatusWifi;
}


/** 是否有网络 */
+(BOOL)isNetworkEnable{
    
    CoreNetWorkStatus networkStatus = [self currentNetWorkStatus];
    
    return networkStatus!=CoreNetWorkStatusUnkhow && networkStatus != CoreNetWorkStatusNone;
}

/** 是否处于高速网络环境：3G、4G、Wifi */
+(BOOL)isHighSpeedNetwork{
    CoreNetWorkStatus networkStatus = [self currentNetWorkStatus];
    return networkStatus == CoreNetWorkStatus3G || networkStatus == CoreNetWorkStatus4G || networkStatus == CoreNetWorkStatusWifi;
}

@end
