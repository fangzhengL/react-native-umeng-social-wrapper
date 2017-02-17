//
//  UMengShareManager.m
//  ieltsmobile
//
//  Created by mac on 16/9/22.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "ZKUmengSocialWrapper.h"
#import <UMSocialCore/UMSocialCore.h>
#import "RCTConvert.h"

#define UMSocalPlatformTypeJsNameNativeValueMap \
@{@"SocialPlatformQQ":@(UMSocialPlatformType_QQ),\
@"SocialPlatformQzone":@(UMSocialPlatformType_Qzone),\
@"SocialPlatformWechatSession":@(UMSocialPlatformType_WechatSession),\
@"SocialPlatformWechatTimeLine":@(UMSocialPlatformType_WechatTimeLine),\
@"SocialPlatformSina":@(UMSocialPlatformType_Sina),}

#define kShareTitle @"上智课，逢考必过"
#define kShareDescription @"英语学习，出国留学，尽在智课！"
#define kShareLink @"http://www.smartstudy.com"

@interface RCTConvert (UMSocelPlatformEnum)
@end

@implementation RCTConvert (UMSocelPlatformEnum)
RCT_ENUM_CONVERTER(UMSocialPlatformType,
                   (UMSocalPlatformTypeJsNameNativeValueMap),
                   UMSocialPlatformType_UnKnown,
                   integerValue)
@end


@implementation ZKUmengSocialWrapper

- (instancetype)init {
  self = [super init];
  if (self) {
//    [UMSocialConfig setFinishToastIsHidden:YES position:UMSocialiToastPositionCenter];
  }
  return self;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(configUMSocialNetworkWithKey:(NSString*)umKey
                  callback:(RCTResponseSenderBlock)callback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[UMSocialManager defaultManager] setUmSocialAppkey:umKey];
    if (callback) {
      callback(@[[NSNull null]]);
    }
  });
}

RCT_EXPORT_METHOD(setPlatform:(UMSocialPlatformType)type
                  key:(NSString*)key
                  secret:(NSString*)secret
                  redirectURL:(NSString*)redirectURL
                  callback:(RCTResponseSenderBlock)callback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL ret = [[UMSocialManager defaultManager] setPlaform:type
                                                     appKey:key
                                                  appSecret:secret
                                                redirectURL:redirectURL];
    if (callback) {
      callback(@[ret ? [NSNull null] : [NSString stringWithFormat:@"failed to config platform: %ld", type]]);
    }
  });
}

RCT_EXPORT_METHOD(addEvent:(NSDictionary *)params type:(NSString *)shareType callback:(RCTResponseSenderBlock)callback) {
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self dispathShareTypeWithShareParams:params
                                shareType:shareType
                                 callback:callback];
  });
}

- (void)dispathShareTypeWithShareParams:(NSDictionary *)params
                              shareType:(NSString *)type
                               callback:(RCTResponseSenderBlock)callback{

  NSLog(@"params =========== %@ share type ==== %@", params, type);
  
  void (^goShare)(UIImage*) = ^(UIImage *image){
    UMSocialPlatformType platform;
    NSString *shareTitle = params[@"mainTitle"] ?: kShareTitle;
    NSString *shareDescription = params[@"subTitle"] ?: kShareDescription;
    NSString *link = params[@"link"] ?: kShareLink;
    
    if ([type isEqualToString:@"weibo"]) {
      platform = UMSocialPlatformType_Sina;
      shareDescription = [NSString stringWithFormat:@"%@ %@ %@",shareTitle, shareDescription, link];
    } else if ([type isEqualToString:@"qq"]) {
      platform = UMSocialPlatformType_QQ;
      shareDescription = [NSString stringWithFormat:@"%@ %@ %@",shareTitle, shareDescription, link];
    } else if ([type isEqualToString:@"wechat"]) {
      platform = UMSocialPlatformType_WechatSession;
    }else if ([type isEqualToString:@"wechat-timeline"]) {
      platform = UMSocialPlatformType_WechatTimeLine;
    }else {
      if (callback) {
        callback(@[@NO]);
      }
      NSAssert(NO, @"not supported platform");
      return;
    }
    
    UMSocialMessageObject *messageObject = [[UMSocialMessageObject alloc] init];
    UMShareWebpageObject *shareLinkData = [[UMShareWebpageObject alloc] init];
    shareLinkData.webpageUrl = link ?: @"";
    shareLinkData.title = shareTitle;
    shareLinkData.descr = shareDescription;
    shareLinkData.thumbImage = image;
    messageObject.shareObject = shareLinkData;
    [[UMSocialManager defaultManager]
     shareToPlatform:platform
     messageObject:messageObject
     currentViewController:nil
     completion:^(id data, NSError *error) {
       //UMSocialPlatformErrorType_Cancel
       NSString *errorMsg = error.localizedDescription ?: [NSString stringWithFormat:@"error code: %ld", error.code];
       if (!error) {
         if (callback) { callback(@[[NSNull null], @YES]); }
         NSLog(@"分享成功");
       }else {
         switch (error.code) {
           case UMSocialPlatformErrorType_Cancel:
             if (callback) { callback(@[errorMsg, @NO]); }
             NSLog(@"取消分享");
             break;
           case UMSocialPlatformErrorType_NotNetWork:
             if (callback) { callback(@[errorMsg, @NO]); }
             NSLog(@"网络错误");
             break;
           case UMSocialPlatformErrorType_ShareFailed:
             if (callback) { callback(@[errorMsg, @NO]); }
             NSLog(@"分享失败");
             break;
           case UMSocialPlatformErrorType_ShareDataTypeIllegal:
             if (callback) { callback(@[errorMsg, @NO]); }
             NSLog(@"不支持的分享数据类型");
             break;
             
           default:
             break;
         }
       }
     }];
  };
  
  NSString *localImagePath = params[@"localImagePath"];
  NSFileManager *fm = [NSFileManager defaultManager];
  if (localImagePath && [fm fileExistsAtPath:localImagePath]) {
    goShare([[UIImage alloc] initWithContentsOfFile:localImagePath]);
  }else {
    NSString *icon = [[[[NSBundle mainBundle] infoDictionary]valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    goShare([UIImage imageNamed:icon]);
  }
  
  ;
}

@end
