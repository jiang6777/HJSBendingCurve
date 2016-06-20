//
//  PVRomoterEXPView.m
//  PowerVision
//
//  Created by hejiangshan on 16/6/14.
//  Copyright © 2016年 PowerVision. All rights reserved.
//

#define SYRealValue(value) ((value)/375.0f*[UIScreen mainScreen].bounds.size.width)
#define criticalX SYRealValue(55)   //上贝塞尔曲线X坐标临界值
#define criticalY SYRealValue(55)   //上贝塞尔曲线Y坐标临界值
#define defaultUpControlPoint CGPointMake(SYRealValue(55) + SYRealValue(55) - SYRealValue(30),SYRealValue(30)) //上默认贝塞尔控制点，下默认贝塞尔控制点与上控制点对称
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:0 green:r/255.0 blue:b/255.0 alpha:1];
#import "HJSBendingView.h"
#import "Masonry.h"
#import "UIViewExt.h"

@interface HJSBendingView ()

@property(nonatomic,strong)CAShapeLayer *upShapeLayer;      //上贝塞尔线
@property(nonatomic,strong)CAShapeLayer *downShapeLayer;    //下贝塞尔线
@property(nonatomic,assign)CGPoint upControlPoint;         //上贝塞尔控制点初始点
@property(nonatomic,assign)CGPoint downControlPoint;       //下贝塞尔控制点初始点
@property(nonatomic,assign)CGFloat incrementalY;            //Y方向移动距离，即增量
@property(nonatomic,assign)CGFloat incrementalX;            //X方向移动距离，即增量
@property(nonatomic,assign)CGPoint historyPoint;
@property(nonatomic,assign)PVGestureMoveDirection direction;

@end

@implementation HJSBendingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        //绘制初始化线条,默认是一条对角线
        [self configLayerLine];
        //添加相关视图
        [self configView];
        //添加滑动手势
        [self addGesture];
    }
    return self;
}

- (void)configView
{
    //中心蓝色圆点
    UIView *centerDotView = [[UIView alloc] init];
    centerDotView.backgroundColor = [UIColor colorWithRed:0 green:201/255.0 blue:255/255.0 alpha:1];
    centerDotView.layer.cornerRadius = SYRealValue(5);
    centerDotView.layer.masksToBounds = true;
    [self addSubview:centerDotView];
    
    [centerDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(SYRealValue(10));
        make.height.mas_equalTo(SYRealValue(10));
    }];
}

//绘制初始化线条,默认是一条对角线
- (void)configLayerLine
{
    self.upControlPoint = defaultUpControlPoint;
    self.downControlPoint = CGPointMake(defaultUpControlPoint.x - (defaultUpControlPoint.x - self.width/2)*2, defaultUpControlPoint.y + (self.height/2 - defaultUpControlPoint.y)*2);
    self.incrementalX = (defaultUpControlPoint.x - criticalX)*0.01;
    self.incrementalY = (criticalY - defaultUpControlPoint.y)*0.01;
    
    //初始化上贝塞尔曲线
    self.upShapeLayer = [[CAShapeLayer alloc] init];
    self.upShapeLayer.strokeColor = [UIColor colorWithRed:108/255.0 green:114/255.0 blue:122/255.0 alpha:1].CGColor;//RGBCOLOR(108, 114, 122).CGColor;
    self.upShapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.upShapeLayer.lineWidth = 0.8;
    UIBezierPath *upBezierPath = [self configBezierPathWithStartPoint:CGPointMake(self.width, 0) withControlPoint:defaultUpControlPoint withEndPoint:CGPointMake(self.width/2, self.height/2)];
    self.upShapeLayer.path = upBezierPath.CGPath;
    [self.layer addSublayer:self.upShapeLayer];
    
    self.downShapeLayer = [[CAShapeLayer alloc] init];
    self.downShapeLayer.strokeColor = [UIColor colorWithRed:108/255.0 green:114/255.0 blue:122/255.0 alpha:1].CGColor;
    self.downShapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.downShapeLayer.lineWidth = 0.8;
    
    UIBezierPath *downBezierPath = [self configBezierPathWithStartPoint:CGPointMake(0, self.height) withControlPoint:self.downControlPoint withEndPoint:CGPointMake(self.width/2, self.height/2)];
    self.downShapeLayer.path = downBezierPath.CGPath;
    [self.layer addSublayer:self.downShapeLayer];
}

- (UIBezierPath *)configBezierPathWithStartPoint:(CGPoint)startPoint withControlPoint:(CGPoint)controlPoint withEndPoint:(CGPoint)endPoint
{
    //初始化贝塞尔曲线
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:startPoint];
    [bezierPath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    return bezierPath;
}

//添加滑动手势
- (void)addGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
}

- (void)panAction:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    CGPoint translation = [gesture translationInView: self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.direction = PVGestureMoveDirectionNone;
        self.historyPoint = translation;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (translation.y < self.historyPoint.y) {
            self.direction = PVGestureMoveDirectionUp;
        } else if (translation.y > self.historyPoint.y) {
            self.direction = PVGestureMoveDirectionDown;
        }
        NSLog(@"translation:%f",translation.y);
        NSLog(@"point:%f",point.y);
        [self reDrawRectBezierPath:translation];
        self.historyPoint = translation;
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        self.historyPoint = CGPointZero;
    }
}

- (void)reDrawRectBezierPath:(CGPoint)currentPoint
{
    /*
    float outputValue = 0;
    if (self.direction == PVGestureMoveDirectionUp) {
        if (self.upControlPoint.y > defaultUpControlPoint.y) {
            self.upControlPoint = CGPointMake(self.upControlPoint.x, self.upControlPoint.y-self.incrementalY);
            outputValue = -(self.upControlPoint.y - defaultUpControlPoint.y)/(criticalY - defaultUpControlPoint.y);
        } else {
            self.upControlPoint = CGPointMake(self.upControlPoint.x-self.incrementalX, self.upControlPoint.y);
            outputValue = (defaultUpControlPoint.x - self.upControlPoint.x)/(defaultUpControlPoint.x - criticalX);
        }
    } else {
        if (self.upControlPoint.x >= defaultUpControlPoint.x) {
            self.upControlPoint = CGPointMake(self.upControlPoint.x, self.upControlPoint.y+self.incrementalY);
            outputValue = - (self.upControlPoint.y - defaultUpControlPoint.y)/(criticalY - defaultUpControlPoint.y);
        } else {
            self.upControlPoint = CGPointMake(self.upControlPoint.x+self.incrementalX, self.upControlPoint.y);
            outputValue = (defaultUpControlPoint.x - self.upControlPoint.x)/(defaultUpControlPoint.x - criticalX);
        }
    }
    if (self.upControlPoint.x <= criticalX) {
        self.upControlPoint = CGPointMake(criticalX, self.upControlPoint.y);
        outputValue = 1.0;
    }
    if (self.upControlPoint.y >= criticalY) {
        self.upControlPoint = CGPointMake(self.upControlPoint.x, criticalY);
        outputValue = -1.0;
    }
    if (self.outputValueBlock != nil) {
        NSString *str = [self notRounding:outputValue afterPoint:2];
        self.outputValueBlock(self,str);
    }
    self.downControlPoint = CGPointMake(self.upControlPoint.x - (self.upControlPoint.x - self.width/2)*2, self.upControlPoint.y + (self.height/2 - self.upControlPoint.y)*2);
    
    UIBezierPath *upBezierPath = [self configBezierPathWithStartPoint:CGPointMake(self.width, 0) withControlPoint:self.upControlPoint withEndPoint:CGPointMake(self.width/2, self.height/2)];
    self.upShapeLayer.path = upBezierPath.CGPath;
    
    UIBezierPath *downBezierPath = [self configBezierPathWithStartPoint:CGPointMake(0, self.height) withControlPoint:self.downControlPoint withEndPoint:CGPointMake(self.width/2, self.height/2)];
    self.downShapeLayer.path = downBezierPath.CGPath;
     */
    
    float outputValue = 0;
    float differenceY = currentPoint.y*0.01;
    NSLog(@"differenceY:%f",differenceY);
    if (self.direction == PVGestureMoveDirectionUp) {
        if (self.upControlPoint.y > defaultUpControlPoint.y) {
            self.upControlPoint = CGPointMake(self.upControlPoint.x, self.upControlPoint.y-fabs(differenceY));
            outputValue = -(self.upControlPoint.y - defaultUpControlPoint.y)/(criticalY - defaultUpControlPoint.y);
        } else {
            self.upControlPoint = CGPointMake(self.upControlPoint.x-fabs(differenceY), self.upControlPoint.y);
            outputValue = (defaultUpControlPoint.x - self.upControlPoint.x)/(defaultUpControlPoint.x - criticalX);
        }
    } else {
        if (self.upControlPoint.x >= defaultUpControlPoint.x) {
            self.upControlPoint = CGPointMake(self.upControlPoint.x, self.upControlPoint.y+fabs(differenceY));
            outputValue = - (self.upControlPoint.y - defaultUpControlPoint.y)/(criticalY - defaultUpControlPoint.y);
        } else {
            self.upControlPoint = CGPointMake(self.upControlPoint.x+fabs(differenceY), self.upControlPoint.y);
            outputValue = (defaultUpControlPoint.x - self.upControlPoint.x)/(defaultUpControlPoint.x - criticalX);
        }
    }
    if (self.upControlPoint.x <= criticalX) {
        self.upControlPoint = CGPointMake(criticalX, self.upControlPoint.y);
        outputValue = 1.0;
    }
    if (self.upControlPoint.y >= criticalY) {
        self.upControlPoint = CGPointMake(self.upControlPoint.x, criticalY);
        outputValue = -1.0;
    }
    if (self.outputValueBlock != nil) {
        NSString *str = [self notRounding:outputValue afterPoint:2];
//        NSLog(@"value:%@",str);
        self.outputValueBlock(self,str);
    }
    self.downControlPoint = CGPointMake(self.upControlPoint.x - (self.upControlPoint.x - self.width/2)*2, self.upControlPoint.y + (self.height/2 - self.upControlPoint.y)*2);
    
    UIBezierPath *upBezierPath = [self configBezierPathWithStartPoint:CGPointMake(self.width, 0) withControlPoint:self.upControlPoint withEndPoint:CGPointMake(self.width/2, self.height/2)];
    self.upShapeLayer.path = upBezierPath.CGPath;
    
    UIBezierPath *downBezierPath = [self configBezierPathWithStartPoint:CGPointMake(0, self.height) withControlPoint:self.downControlPoint withEndPoint:CGPointMake(self.width/2, self.height/2)];
    self.downShapeLayer.path = downBezierPath.CGPath;
    
}

- (NSString *)notRounding:(float)price afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, rect.size.height/2);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height/2);
    CGContextMoveToPoint(context, rect.size.width/2, 0);
    CGContextAddLineToPoint(context, rect.size.width/2, rect.size.height);
    CGContextDrawPath(context, kCGPathEOFillStroke) ;    //绘制完成
    CGContextStrokePath(context);
    
    CGFloat lengths[] = {3,5};
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //设置线宽
    CGContextSetLineDash(ctx, 0, lengths, 2);  //画虚线
    //设置画笔颜色
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
}

//调整曲线
- (void)updateCurve:(float)value
{
    float distance = 0;
    if (value > 0) {
        distance = (defaultUpControlPoint.x - criticalX)*fabsf(value);
        self.upControlPoint = CGPointMake(defaultUpControlPoint.x-distance, defaultUpControlPoint.y);
    } else {
        distance = (criticalY - defaultUpControlPoint.y)*fabsf(value);
        self.upControlPoint = CGPointMake(defaultUpControlPoint.x, defaultUpControlPoint.y + distance);
    }

    if (self.upControlPoint.x <= criticalX) {
        self.upControlPoint = CGPointMake(criticalX, self.upControlPoint.y);
    }
    if (self.upControlPoint.y >= criticalY) {
        self.upControlPoint = CGPointMake(self.upControlPoint.x, criticalY);
    }
    self.downControlPoint = CGPointMake(self.upControlPoint.x - (self.upControlPoint.x - self.width/2)*2, self.upControlPoint.y + (self.height/2 - self.upControlPoint.y)*2);
    
    UIBezierPath *upBezierPath = [self configBezierPathWithStartPoint:CGPointMake(self.width, 0) withControlPoint:self.upControlPoint withEndPoint:CGPointMake(self.width/2, self.height/2)];
    self.upShapeLayer.path = upBezierPath.CGPath;
    
    UIBezierPath *downBezierPath = [self configBezierPathWithStartPoint:CGPointMake(0, self.height) withControlPoint:self.downControlPoint withEndPoint:CGPointMake(self.width/2, self.height/2)];
    self.downShapeLayer.path = downBezierPath.CGPath;
}

@end
