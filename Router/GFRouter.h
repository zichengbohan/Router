//
//  GFRouter.h
//  Router
//  https://www.jianshu.com/p/6802a166b545
//  Created by xbm on 2019/2/18.
//  Copyright © 2019 guomei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface GFRouter : NSObject

+ (BOOL)openURL:(NSURL *)URL;

+ (UIViewController *)getControllerFromClassName:(NSString *)controllerName;


@end

NS_ASSUME_NONNULL_END
