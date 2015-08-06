//
//  ViewController.m
//  JKNetWorkStatus
//
//  Created by Jack on 15/8/6.
//  Copyright (c) 2015年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "JKNetWorkStatus.h"



@interface ViewController ()<JKNetWorkStatusDelegate>

@property (weak, nonatomic) IBOutlet UILabel *netLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [JKNetWorkStatus beginNotiNetwork:self];
    [self coreNetworkChangeNoti:nil];
}



- (void)coreNetworkChangeNoti:(NSNotification *)noti
{
    NSString * statusString = [JKNetWorkStatus currentNetWorkStatusString];
    self.netLabel.text = statusString;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSString * statusString = [JKNetWorkStatus currentNetWorkStatusString];
//    self.netLabel.text = statusString;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
