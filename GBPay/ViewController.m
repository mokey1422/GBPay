//
//  ViewController.m
//  GBPay
//
//  Created by 张国兵 on 15/7/24.
//  Copyright (c) 2015年 zhangguobing. All rights reserved.

#import "ViewController.h"
#import "GBPayManager.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ViewController (){
    
    
}
@property (nonatomic,retain)UISegmentedControl *paySegment;
@end

@implementation ViewController
-(void)dealloc{
    //移除监听
    [[NSNotificationCenter defaultCenter ]removeObserver:self];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.paySegment=[[UISegmentedControl alloc]initWithItems:@[@"微信",@"支付宝",@"银联支付"]];
    self.paySegment.frame=CGRectMake(100,64, 200, 40);
    self.paySegment.center=CGPointMake(self.view.bounds.size.width/2, 90);
    [self.paySegment setSelectedSegmentIndex:0];
    self.paySegment.tintColor=[UIColor orangeColor];
    [self.view addSubview:self.paySegment];
    
    UIButton*payBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    payBtn.frame=CGRectMake(20, 120, 100, 40);
    payBtn.center=CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    [payBtn setTitle:@"支付" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    payBtn.clipsToBounds=YES;
    payBtn.layer.cornerRadius=5;
    payBtn.backgroundColor=[UIColor orangeColor];
    [self.view addSubview:payBtn];
    //注册监听-支付宝
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dealAlipayResult:) name:@"alipayResult" object:nil];
    //注册监听-微信
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dealWXpayResult:) name:@"WXpayresult" object:nil];
    
    

}
#pragma mark-不同的支付方式
-(void)pay:(id)btn{
    switch ([self.paySegment selectedSegmentIndex]) {
        case 0:
            [self wxPay];
            break;
        case 1:
            [self aliPay];
            break;
        case 2:
            [self unionPay];
        default:
            break;
    }
    
}
#pragma mark-微信支付
- (void)wxPay {
    //测试环境随机订单号，实际生产环境应该走服务器
    NSString *orderno   = [NSString stringWithFormat:@"%ld",time(0)];
    [GBPayManager wxpayWithOrderID:orderno orderTitle:@"雅思书籍全部5折大促销" amount:@"0.01"];
}
#pragma mark-支付宝支付
-(void)aliPay{
    //测试环境随机订单号，实际生产环境应该走服务器
    [GBPayManager alipayWithProductName:@"雅思" amount:@"0.01" tradeNO:[self generateTradeNO] notifyURL:@"www.baidu.com" productDescription:@"雅思书籍全部5折大促销" itBPay:@"30"];
    
}
#pragma mark-银联支付
-(void)unionPay{
   
    UIAlertView*al=[[UIAlertView alloc]initWithTitle:@"别点了并没什么卵用" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [al show];
}

-(void)dealAlipayResult:(NSNotification*)notification{
    NSString*result=notification.object;
    
    if([result isEqualToString:@"9000"]){
      
        //在这里写支付成功之后的回调操作
         NSLog(@"支付宝支付成功");
        
    }else{
        
        //在这里写支付失败之后的回调操作
         NSLog(@"支付宝支付失败");
    }
    
    
    
}
-(void)dealWXpayResult:(NSNotification*)notification{
    NSString*result=notification.object;
    if([result isEqualToString:@"1"]){
       
        //在这里写支付成功之后的回调操作
         NSLog(@"微信支付成功");
        
    }else{
        //在这里写支付失败之后的回调操作
         NSLog(@"微信支付失败");
    }
    
    
    
}
#pragma mark ==============产生随机订单号==============


-(NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

-(void)showAlerterWithTitle:(NSString*)title{
    
    UIAlertView*al=[[UIAlertView alloc]initWithTitle:title message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [al show];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
