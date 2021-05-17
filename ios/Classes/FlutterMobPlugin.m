#import "FlutterMobPlugin.h"
#import <SecVerify/SVSDKHyVerify.h>
#import <MOBFoundation/MobSDK+Privacy.h>

static FlutterMethodChannel *channel = nil;

@implementation FlutterMobPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    channel = [FlutterMethodChannel methodChannelWithName:@"xns/flutter_mob_plugin" binaryMessenger:[registrar messenger]];
    FlutterMobPlugin *instance = [[FlutterMobPlugin alloc]init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void) handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = [call arguments];
    if ([call.method isEqualToString:@"getStatus"]) {
        if (arguments[@"status"] == nil)
            result(0);
        BOOL status = [arguments[@"status"] boolValue];
        [self getStatus:status];
    } else if([call.method isEqualToString:@"preLogin"]) {
        // 预登录  判断是否获取帐号成功
        [self proLogin];
    } else if ([call.method isEqualToString:@"loginAuth"]) {
        [self loginAuth];
    } else if ([call.method isEqualToString:@"isVerifyEnable"]) {
        BOOL isVerifyEnable = [self isVerifyEnable];
        result(@(isVerifyEnable));
    } else if ([call.method isEqualToString:@"cleanPhoneScripCache"]) {
        [self cleanPhoneScripCache];
    } else if ([call.method isEqualToString:@"getCurrentOperatorType"]) {
        NSString *operatorType = [self getCurrentOperatorType];
        result(operatorType);
    }
}

#pragma mark - SDK 隐私授权
- (void) getStatus:(BOOL) status {
    [MobSDK uploadPrivacyPermissionStatus:status onResult:^(BOOL success) {
        [channel invokeMethod:@"login.privacyPermissionStatus" arguments:@{@"success": @(success)}];
    }];
}

#pragma -mark - SDK 预取号
- (void)proLogin {
    [SVSDKHyVerify preLogin:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
        if (error == nil && resultDic != nil && [resultDic isKindOfClass:NSDictionary.class]) {
            [channel invokeMethod:@"login.preLoginResult" arguments:@{@"operator": resultDic[@"operator"]}];
        } else {
            [channel invokeMethod:@"login.preLoginResultFail" arguments:error];
        }
    }];
}
#pragma mark - SDK 请求授权 + 一键登录
- (void)loginAuth {
    // 创建一个ui配置对象
    SVSDKHyUIConfigure *uiConfigure = [[SVSDKHyUIConfigure alloc]init];
    // 获取登录页面
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    // 设置currentViewController(必传)
    uiConfigure.currentViewController = vc;
    // 定制化属性，开发者手动控制关闭授权页
    uiConfigure.manualDismiss = @(YES);

    [SVSDKHyVerify openAuthPageWithModel:uiConfigure openAuthPageListener:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
        if (error != nil) {
            [channel invokeMethod:@"login.auth" arguments:resultDic];
        } else {
            [channel invokeMethod:@"login.authFail" arguments:error];
        }
    } cancelAuthPageListener:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
        [channel invokeMethod:@"login.cancel" arguments:resultDic];
    } oneKeyLoginListener:^(NSDictionary * _Nullable resultDic, NSError * _Nullable error) {
        // 关闭页面
        [SVSDKHyVerify finishLoginVcAnimated:YES Completion:nil];
        if (error == nil) {
            [channel invokeMethod:@"login.success"
                         arguments:@{
                             @"operator": resultDic[@"operator"],
                             @"opToken": resultDic[@"opToken"],
                             @"token": resultDic[@"token"]
                         }];
        } else {
            [channel invokeMethod:@"login.fail" arguments:error];
        }
    }];
}

#pragma mark - SDK 本机是否可以发起验证
- (BOOL) isVerifyEnable {
    return [SVSDKHyVerify isVerifyEnable];
}

#pragma mark - SDK 清空SDK内部预取号缓存
- (void) cleanPhoneScripCache {
    [SVSDKHyVerify clearPhoneScripCache];
}

#pragma mark - SDK 获取当前流量卡运营商 CMCC:移动 CUCC:联通 CTCC:电信 UNKNOW:未知
- (NSString *)getCurrentOperatorType {
    return [SVSDKHyVerify getCurrentOperatorType];
}
@end
