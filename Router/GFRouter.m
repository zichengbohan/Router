//
//  GFRouter.m
//  Router
//
//  Created by xbm on 2019/2/18.
//  Copyright © 2019 guomei. All rights reserved.
//

#import "GFRouter.h"
#import <objc/runtime.h>

@implementation GFRouter

+ (instancetype)shareRouter {
    static GFRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] init];
    });
    return instance;
}

+ (BOOL)openURL:(NSURL *)URL {
    UIViewController *controller = [GFRouter getControllerFromURL:URL];
    if (!controller) return NO;
    NSMutableDictionary *paraDIc = [GFRouter getParaWith:URL];
    [GFRouter display:controller with:paraDIc];
    return YES;
}

+ (void)display:(UIViewController *)controller with:(NSMutableDictionary *)paraDic {
    UIViewController *currentVC = [GFRouter getCurrentVC];
    if (currentVC.class == controller.class) {
        [GFRouter setPropertyWith:paraDic and:currentVC];
    } else {
        [GFRouter setPropertyWith:paraDic and:controller];
        [GFRouter pushWith:controller];
    }
}

/**
 通过URL获取控制器

 @param URL <#URL description#>
 @return <#return value description#>
 */
+ (UIViewController *)getControllerFromURL:(NSURL *)URL {
    if (URL.path.length > 1) {
        NSString *subPath = [URL.path substringFromIndex:1];
        UIViewController *vc = [GFRouter getControllerFromClassName:subPath];
        
        return vc;
    } else {
        return nil;
    }
}


/**
 通过类名获取控制器

 @param controllerName <#controllerName description#>
 @return <#return value description#>
 */
+ (UIViewController *)getControllerFromClassName:(NSString *)controllerName {
    const char * name = [controllerName cStringUsingEncoding:NSASCIIStringEncoding];
    
    //从一个类名返回一个类
    Class newClass =objc_getClass(name);
    
    //创建对象
    if (newClass == nil) return nil;
    return [[newClass alloc] init];
    
}


/**
 获取控制器属性参数

 @param URL <#URL description#>
 @return <#return value description#>
 */
+ (NSMutableDictionary *)getParaWith:(NSURL *)URL {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    NSArray<NSURLQueryItem *> *queryItems = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:false].queryItems;
    
    for (NSURLQueryItem *item in queryItems) {
        properties[item.name] = item.value;
    }
    return properties;
}

/**
 属性赋值

 @param paraDIc <#paraDIc description#>
 @param controller <#controller description#>
 @return <#return value description#>
 */
+ (UIViewController *)setPropertyWith:(NSMutableDictionary *)paraDIc and:(UIViewController *)controller {
    [paraDIc enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([GFRouter checkIsExistPropertyWIthInstance:controller verifyPropertyName:key]) {
            //李彤kvc赋值
            [controller setValue:obj forKey:key];
        }
    }];
    return controller;
}


/**
 检测这个对象是否存在该属性

 @param instance <#instance description#>
 @param verifyPropertyName <#verifyPropertyName description#>
 @return <#return value description#>
 */
+ (BOOL)checkIsExistPropertyWIthInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName {
    unsigned int outCount, i;
    
    //获取对象里的属性列表
    objc_property_t * properties = class_copyPropertyList([instance class], &outCount);
    
    for (i = 0; i < outCount ; i++) {
        objc_property_t property = properties[i];
        //属性名转换成字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    return NO;
}

/**
 获取当前viewController

 @return <#return value description#>
 */
+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmWin in windows) {
            if (tmWin.windowLevel == UIWindowLevelNormal) {
                window = tmWin;
                break;
            }
        }
    }
    id nextResponder = nil;
    UIViewController *appRootVC = window.rootViewController;
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    } else {
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbar = (UITabBarController *)nextResponder;
        UINavigationController *nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        
        result =nav.childViewControllers.lastObject;
    } else if ([nextResponder isKindOfClass:[UINavigationController class]]) {
        UIViewController *nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    } else {
        result = nextResponder;
    }
    
    return result;
}

/**
 导航退出控制器

 @param controller <#controller description#>
 */
+ (void)pushWith:(UIViewController *)controller {
    UIViewController *currentVC = [GFRouter getCurrentVC];
    [currentVC presentViewController:controller animated:YES completion:nil];
    
    return;
    UINavigationController *nc = [GFRouter getCurrentVC].navigationController;
    controller.hidesBottomBarWhenPushed = YES;
    if (nc) {
        [nc pushViewController:controller animated:YES];
    }
}

@end
