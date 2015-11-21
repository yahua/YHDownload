//
//  UIView+MethodExt.h
//  ND91U
//
//  Created by 颜志炜 on 14-1-14.
//  Copyright (c) 2014年 nd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MethodExt)

@end

@interface UIView (viewcontroller)
/**
 *    获取当前实例对应的viewcontroller
 *
 *    @return 返回搜索到的viewcontroller，否则返回nil
 */
- (UIViewController *)viewController;
@end

@interface UIView (frameutil)
/**
 *    top = frame.origin.y
 */
@property (nonatomic, assign) CGFloat top;

/**
 *    left = frame.origin.x
 */
@property (nonatomic, assign) CGFloat left;

/**
 *    bottom = frame.origin.y + frame.size.height
 */
@property (nonatomic, assign) CGFloat bottom;

/**
 *    right = frame.origin.x + frame.size.width
 */
@property (nonatomic, assign) CGFloat right;

/**
 *    width = frame.size.width
 */
@property (nonatomic, assign) CGFloat width;

/**
 *    height = frame.size.height
 */
@property (nonatomic, assign) CGFloat height;

/**
 *    centerX = center.x
 */
@property (nonatomic, assign) CGFloat centerX;

/**
 *    centerY = center.y
 */
@property (nonatomic, assign) CGFloat centerY;

/**
 *    当前实例在屏幕上的x坐标
 */
@property (nonatomic, readonly) CGFloat screenX;

/**
 *    当前实例在屏幕上的y坐标
 */
@property (nonatomic, readonly) CGFloat screenY;

/**
 *    当前实例在屏幕上的x坐标（scroll view适用）
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 *    当前实例在屏幕上的y坐标（scroll view适用）
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 *    当前实例在屏幕上的位置大小
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 *    origin = frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 *    size = frame.size
 */
@property (nonatomic) CGSize size;

/**
 *    返回实例在竖屏下的宽或横屏下的高
 */
@property (nonatomic, readonly) CGFloat orientationWidth;

/**
 *    返回实例在竖屏下的高或横屏下的宽
 */
@property (nonatomic, readonly) CGFloat orientationHeight;
@end

@interface UIView (view)
/**
 *    向下递归搜索首个指定类的子view（包括当前view）
 *
 *    @param cls 指定的类
 *
 *    @return 返回指定类的view，找不到返回nil
 */
- (UIView *)descendantOrSelfWithClass:(Class)cls;

/**
 *    向上递归搜索首个指定类的父view（包括当前view）
 *
 *    @param cls 指定的类
 *
 *    @return 返回指定类的view，找不到返回nil
 */
- (UIView *)ancestorOrSelfWithClass:(Class)cls;

/**
 *    移除实例所有子view
 */
- (void)removeAllSubviews;
@end

@interface UIView(action)
/**
*    给实例附加一个点击事件（单击）的执行回调
*
*    @param block 单击动作执行回调
*/
- (void)setTapActionWithBlock:(void (^)(void))block;

/**
 *    给实例附加一个长按事件的执行回调
 *
 *    @param block 长按动作执行回调
 */
- (void)setLongPressActionWithBlock:(void (^)(void))block;
@end