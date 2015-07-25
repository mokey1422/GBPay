//
//  GBPayManager.m
//  GBPay
//
//  Created by 张国兵 on 15/7/24.
//  Copyright (c) 2015年 zhangguobing. All rights reserved.
//

#import "GBPayManager.h"

@implementation GBPayManager
/**
 *  针对多个用户用户配置信息请求自服务器
 *
 *  @param partner            合作者身份ID
 *  @param seller             卖家支付宝账号
 *  @param tradeNO            商户网站唯一订单号
 *  @param productName        商品名称
 *  @param productDescription 商品详情
 *  @param amount             总金额
 *  @param notifyURL          服务器异步通知页面路径
 *  @param itBPay             未付款交易的超时时间
 */
+ (void)alipayWithPartner:(NSString *)partner
                   seller:(NSString *)seller
                  tradeNO:(NSString *)tradeNO
              productName:(NSString *)productName
       productDescription:(NSString *)productDescription
                   amount:(NSString *)amount
                notifyURL:(NSString *)notifyURL
                   itBPay:(NSString *)itBPay
{
    
    
    
    
    [self alipayWithPartner:partner
                     seller:seller
                    tradeNO:tradeNO
                productName:productName
         productDescription:productDescription
                     amount:amount
                  notifyURL:notifyURL service:@"mobile.securitypay.pay" paymentType:@"1"
               inputCharset:@"UTF-8"
                     itBPay:itBPay
                 privateKey:PartnerPrivKey
                  appScheme:kAppScheme];
    
}
/**
 *  只针对单一用户数据本地写死
 *
 *  @param productName        商品名称
 *  @param amount             商品金额
 *  @param notifyURL          服务器异步通知页面路径
 *  @param productDescription 商品详情
 *  @param itBPay             未付款交易的超时时间
 */
+(void)alipayWithProductName:(NSString *)productName
                      amount:(NSString *)amount
                     tradeNO:(NSString *)tradeNO
                   notifyURL:(NSString *)notifyURL
          productDescription:(NSString *)productDescription
                      itBPay:(NSString *)itBPay;{
    
    [self alipayWithPartner:PartnerID
                     seller:SellerID
                    tradeNO:tradeNO
                productName:productName
         productDescription:productDescription
                     amount:amount
                  notifyURL:notifyURL service:@"mobile.securitypay.pay" paymentType:@"1"
               inputCharset:@"UTF-8"
                     itBPay:itBPay
                 privateKey:PartnerPrivKey
                  appScheme:kAppScheme];
    
    
    
    
    
}

// 包含所有必要的参数
+ (void)alipayWithPartner:(NSString *)partner
                   seller:(NSString *)seller
                  tradeNO:(NSString *)tradeNO
              productName:(NSString *)productName
       productDescription:(NSString *)productDescription
                   amount:(NSString *)amount
                notifyURL:(NSString *)notifyURL
                  service:(NSString *)service
              paymentType:(NSString *)paymentType
             inputCharset:(NSString *)inputCharset
                   itBPay:(NSString *)itBPay
               privateKey:(NSString *)privateKey
                appScheme:(NSString *)appScheme {
    
    Order *order = [[Order alloc]init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = tradeNO;
    order.productName = productName;
    order.productDescription = productDescription;
    order.amount = amount;
    order.notifyURL = notifyURL;
    order.service = service;
    order.paymentType = paymentType;
    order.inputCharset = inputCharset;
    order.itBPay = itBPay;
    
    
    // 将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    // 获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循 RSA 签名规范, 并将签名字符串 base64 编码和 UrlEncode
    
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
        
        
    }
    
    
}
/**
 *  针对多个商户的微信支付
 *
 *  @param orderID    支付订单号
 *  @param orderTitle 订单的商品描述
 *  @param amount     订单总额
 *  @param notifyURL  支付结果异步通知
 *  @param seller     商户号（收款账号）
 */
+(void)wxpayWithOrderID:(NSString*)orderID
             orderTitle:(NSString*)orderTitle
                 amount:(NSString*)amount
                seller :(NSString *)seller{
    
    //微信支付的金额单位是分转化成我们比较常用的'元'
    NSString*realPrice=[NSString stringWithFormat:@"%.f",amount.floatValue*100];
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc];
    //初始化支付签名对象
    [req init:APP_ID mch_id:seller];
    //设置密钥
    [req setKey:PARTNER_ID];

    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPay_demo:orderID title:orderTitle price:realPrice];
    
    if(dict == nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        
        [self alert:@"提示信息" msg:debug];
        
        NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        BOOL status = [WXApi sendReq:req];
        NSLog(@"%d",status);
        
    }

}

/**
 *  单一用户微信支付
 *
 *  @param orderID    支付订单号
 *  @param orderTitle 订单的商品描述
 *  @param amount     订单总额
 */
+(void)wxpayWithOrderID:(NSString*)orderID
             orderTitle:(NSString*)orderTitle
                 amount:(NSString*)amount{
    
    //微信支付的金额单位是分转化成我们比较常用的'元'
    NSString*realPrice=[NSString stringWithFormat:@"%.f",amount.floatValue*100];
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc];
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    //}}}
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPay_demo:orderID title:orderTitle price:realPrice];
    
    if(dict == nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        
        [self alert:@"提示信息" msg:debug];
        
        NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        BOOL status = [WXApi sendReq:req];
        NSLog(@"%d",status);
        
    }

    
    
    
    
}
//客户端提示信息
+(void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}
@end
