//
//  PVRomoterEXPView.h
//  PowerVision
//
//  Created by hejiangshan on 16/6/14.
//  Copyright © 2016年 PowerVision. All rights reserved.
//
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    PVGestureMoveDirectionNone,
    PVGestureMoveDirectionUp,       //手势向上滑动
    PVGestureMoveDirectionDown,     //手势向下滑动
} PVGestureMoveDirection;


@interface HJSBendingView : UIView

//调整曲线
- (void)updateCurve:(float)value;

@property(nonatomic,copy)void(^outputValueBlock)(HJSBendingView *expView,NSString *value);

@end
