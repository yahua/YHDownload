//
//  AppDelegate.h
//  YHDownload
//
//  Created by wsw on 15/11/19.
//  Copyright © 2015年 wsw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)();
@property (strong, nonatomic) UIWindow *window;


@end

