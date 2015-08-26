#GBPay<br>
##这是微信和支付宝的二合一版本 如果你之前有用过我封装的微信和支付宝一下的就不用看了，本来我是打算把银联支付集成进来但是银联支付的订单提交完全脱离不开后台的接口配置，少了后台完全没有意义所以就没加上<br>
#使用说明：<br>
* 首先还是老规矩把文件夹先拖进你的工程里面<br>
* 加入需要配置的系统库libsqlite3.0.dylib、libz.dzlib、SystemConfiguration.frame。如果有问题可能提示查无此类这个问题一般会出现在微信支付的包里，不要紧在相应的类里面包含一下#import <UIKit/UIKit.h>就ok了。<br>
* 点击项目名称,点击“Build Settings”选项卡,在搜索框中,以关键字“search” 搜索,对“Header Search Paths”增加头文件路径:
    “$(SRCROOT)/项目名称/GBPay/GBPayLib/Alipay”（注意：不包括引号，如果不是放到项目根目录下，请在项目名称后面加上相应的目录名）,编译一下没什么问题进行下一步，如果有问题可能上面的配置不对重新配置一遍；<br>
* 在GBPayManagerConfig.h文件里面配置好自己的账户信息资料，将相应的信息直接替换成自己审核通过的响应的平台资料就可以了，在这里不一一陈述<br>
* 在使用的类里包含头文件#import "GBPayManager.h"直接调用相应的方法即可，另外为了处理平台反馈给我的处理结果这里注册了监听，监听支付结果做相应的处理，详情见demo<br>
* 接下来就是配置appdelegate里的设置，包含头文件#import "GBPayManager.h"因为微信支付调用回调的时候用的是协议代理，这里要在appdelegate里面包含一下代理协议详情见demo<br>
```
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 //向微信注册
 [WXApi registerApp:APP_ID withDescription:nil];
 return YES;
 }
 
 #pragma mark - 微信支付回调
 -(void) onResp:(BaseResp*)resp
 {
 NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
 NSString *strTitle;
 
 if([resp isKindOfClass:[SendMessageToWXResp class]])
 {
 strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
 }
 if([resp isKindOfClass:[PayResp class]]){
 //支付返回结果，实际支付结果需要去微信服务器端查询
 strTitle = [NSString stringWithFormat:@"支付结果"];
 
 switch (resp.errCode) {
 case WXSuccess:
 strMsg = @"支付结果：成功！";
 NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
 
 [[NSNotificationCenter defaultCenter] postNotificationName:@"WXpayresult" object:@"1"];
 
 break;
 
 default:
 strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
 NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
 [[NSNotificationCenter defaultCenter] postNotificationName:@"WXpayresult" object:@"0"];
 
 
 break;
 }
 
 }
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
 [alert show];
 }
 
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
 
 if(!url){
 
 return NO;
 }
 
 if ([url.host isEqualToString:@"safepay"]){
 //如果极简 SDK 不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给 SDK if ([url.host isEqualToString:@"safepay"]) {
 [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
 NSLog(@"result = %@",resultDic);
 
 [[NSNotificationCenter defaultCenter]postNotificationName:@"alipayResult" object:[resultDic objectForKey:@"resultStatus"]];
 
 }];
 }
 if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
 [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
 NSLog(@"result = %@",resultDic);
 }];
 }
 
 if ([url.host isEqualToString:@"pay"]) { //微信支付
 return  [WXApi handleOpenURL:url delegate:self];
 
 }
 
 return YES;
 }
 
```
* 点击项目名称,点击“Info”选项卡，在URL types里面添加一项，Identifier可以不填，用于支付宝处理回到应用的事件；支付宝提交的时候有这个参数设置所以支付宝的URL schemes必须和appScheme的值相同，微信的URL schemes就是他的appID<br>
* 本来想将银联支付集成进去但是突然意识到银联支付缺少后台支持貌似没有什么意义他的规则是客户端提交预订单信息给商户后台，商户后台再提交给银联后台，银联后台返回流水号TN给商户后台，商户后台返回给客户端，客户端拿到tn才能调用控件支付，整个过程的订单信息都是走接口的没有暴露参数给我们所以没有什么集成意义就不加了<br>

## 最后啰嗦几句做几点说明
  * 处于安全性来说的话不建议将配置参数写在本地最好是来自服务器，但是这个地方还是给你们留了<br>
  * 暴露了几个方法一个是针对的那一用户的，另一个是多个用户的具体的看需求而定<br>
#效果图：<br>

![image](https://github.com/mokey1422/gifResource/blob/master/pay.gif)


