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
#import <objc/runtime.h>

#define UMSocalPlatformTypeJsNameNativeValueMap \
@{@"SocialPlatformQQ":@(UMSocialPlatformType_QQ),\
@"SocialPlatformQzone":@(UMSocialPlatformType_Qzone),\
@"SocialPlatformWechatSession":@(UMSocialPlatformType_WechatSession),\
@"SocialPlatformWechatTimeLine":@(UMSocialPlatformType_WechatTimeLine),\
@"SocialPlatformSina":@(UMSocialPlatformType_Sina),}

#define kShareTitle @"上智课，逢考必过"
#define kShareDescription @"英语学习，出国留学，尽在智课！"
#define kShareLink @"http://www.smartstudy.com"

BOOL applicationOpenURLSourceApplicationAnnotation(id sender,
                                                   SEL selector,
                                                   UIApplication *application,
                                                   NSURL *url,
                                                   NSString *sourceApp,
                                                   id annote) {
  return NO;
}

BOOL applicationOpenURLSourceApplicationAnnotation2(id sender,
                                                    SEL selector,
                                                    UIApplication *application,
                                                    NSURL *url,
                                                    NSString *sourceApp,
                                                    id annote) {
  BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
  if (result) {
    return result;
  } else {
    SEL originalSelectorToFallback = @selector(application2:openURL:sourceApplication:annotation:);
    if ([application respondsToSelector:originalSelectorToFallback]) {
      NSMethodSignature *methodSig = [application methodSignatureForSelector:originalSelectorToFallback];
      NSInvocation *inv = [NSInvocation invocationWithMethodSignature:methodSig];
      [inv setSelector:originalSelectorToFallback];
      [inv setTarget:application];
      [inv setArgument:&application atIndex:2];
      [inv setArgument:&url atIndex:3];
      [inv setArgument:&sourceApp atIndex:4];
      [inv setArgument:&annote atIndex:5];
      [inv invoke];
      
      NSUInteger length = [methodSig methodReturnLength];
      void *buffer = (void*)malloc(length);
      [inv getReturnValue:buffer];
      BOOL ret = *((BOOL*)buffer);
      free(buffer);
      return ret;
    } else {
      NSLog(@"should not happen");
      return NO;
    }
  }
}


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
    BOOL ret = [self swizzleAppDelegateOpenURLMethod];
    if (callback) {
      callback(@[ret ? [NSNull null] : @"failed to swizzle openurl method of appdelegate"]);
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

RCT_EXPORT_METHOD(addEvent:(NSDictionary *)params type:(UMSocialPlatformType)shareType callback:(RCTResponseSenderBlock)callback) {
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self dispathShareTypeWithShareParams:params
                                shareType:shareType
                                 callback:callback];
  });
}

- (NSSet<NSNumber*> *)supportedPlatforms {
  static dispatch_once_t onceToken;
  static NSSet<NSNumber*> *ret = nil;
  dispatch_once(&onceToken, ^{
    NSMutableSet<NSNumber*> *platforms = [NSMutableSet set];
    [platforms addObjectsFromArray:
  @[@(UMSocialPlatformType_Sina),
    @(UMSocialPlatformType_QQ),
    @(UMSocialPlatformType_WechatSession),
    @(UMSocialPlatformType_WechatTimeLine)]];
    ret = platforms;
  });
  return ret;
}

- (void)dispathShareTypeWithShareParams:(NSDictionary *)params
                              shareType:(UMSocialPlatformType)type
                               callback:(RCTResponseSenderBlock)callback{

  NSLog(@"params =========== %@ share type ==== %ld", params, type);
  
  void (^goShare)(UIImage*) = ^(UIImage *image){
    NSString *shareTitle = params[@"mainTitle"] ?: kShareTitle;
    NSString *shareDescription = params[@"subTitle"] ?: kShareDescription;
    NSString *link = params[@"link"] ?: kShareLink;
    if ([[self supportedPlatforms] containsObject:@(type)]) {
      shareDescription = [NSString stringWithFormat:@"%@ %@ %@",shareTitle, shareDescription, link];
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
     shareToPlatform:type
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
  };
}

- (SEL)originalSelector {
  return @selector(application:openURL:sourceApplication:annotation:);
}

- (SEL)swizzleSelector {
  return @selector(application2:openURL:sourceApplication:annotation:);
}

- (BOOL)swizzleAppDelegateOpenURLMethod {
  @synchronized (self) {
    NSObject *appDelegate = [UIApplication sharedApplication].delegate;
    Class appDelegateCls = appDelegate.class;
    SEL originalSel = [self originalSelector];
    SEL newSelector = [self swizzleSelector];
    if (![self.class tryAddMethodForClass:appDelegateCls selector:originalSel imp:(IMP)applicationOpenURLSourceApplicationAnnotation types:"c@:@@@@"]) {
      NSLog(@"failed to addMethod of us to app delegate for selector: %@", NSStringFromSelector(originalSel));
      return NO;
    }
    if (![self.class tryAddMethodForClass:appDelegateCls selector:newSelector imp:(IMP)applicationOpenURLSourceApplicationAnnotation2 types:"c@:@@@@"]) {
      NSLog(@"failed to addMethod of us to app delegate for selector: %@", NSStringFromSelector(originalSel));
      return NO;
    }

    [self exchangeMethod];
    return YES;
  }
}

- (void)restoreSwizzle {
  @synchronized (self) {
    [self exchangeMethod];
  }
}

- (void)exchangeMethod {
  NSObject *appDelegate = [UIApplication sharedApplication].delegate;
  Class appDelegateCls = appDelegate.class;

  SEL originalSel = [self originalSelector];
  Method originalMethod = class_getInstanceMethod(appDelegateCls, originalSel);
  IMP imp = class_getMethodImplementation(appDelegateCls, originalSel);
  SEL newSelector = [self swizzleSelector];
  Method newMethod = class_getInstanceMethod(appDelegateCls, newSelector);
  IMP imp2 = class_getMethodImplementation(appDelegateCls, newSelector);
  method_exchangeImplementations(originalMethod, newMethod);
}

+ (BOOL)tryAddMethodForClass:(Class)destClass selector:(SEL)sel imp:(IMP)imp types:(char *)types {
  if (![destClass instancesRespondToSelector:sel]) {
    if (!class_addMethod(destClass, sel, imp, types)) {
      NSLog(@"failed to add method for class: %@ selector: %@",
            NSStringFromClass(destClass),
            NSStringFromSelector(sel));
      return NO;
    }
  }
  return YES;
}

- (NSDictionary *)constantsToExport
{
  return @{
           @"SocialPlatformQQ": @"QQ好友",
           @"SocialPlatformQzone": @"QQ空间",
           @"SocialPlatformWechatSession": @"微信好友",
           @"SocialPlatformWechatTimeLine": @"微信朋友圈",
           @"SocialPlatformSina": @"新浪微博",
            };
}
@end
