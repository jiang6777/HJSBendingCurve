//
//  ViewController.m
//  HJSBendingCurve
//
//  Created by hejiangshan on 16/6/20.
//  Copyright © 2016年 飞兽科技. All rights reserved.
//

#import "ViewController.h"
#import "HJSBendingView.h"
#import "Masonry.h"
#define SYRealValue(value) ((value)/375.0f*[UIScreen mainScreen].bounds.size.width)

@interface ViewController ()
@property(nonatomic,strong)UILabel *outputLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
}

- (void)configView
{
    __weak ViewController *this = self;
    HJSBendingView *bendingView = [[HJSBendingView alloc] initWithFrame:CGRectMake(0, 0, SYRealValue(110), SYRealValue(110))];
    bendingView.outputValueBlock = ^(HJSBendingView *bendingView,NSString *value) {
        this.outputLabel.text = value;
    };
    [self.view addSubview:bendingView];
    
    [bendingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.width.mas_equalTo(SYRealValue(110));
        make.height.mas_equalTo(SYRealValue(110));
    }];
    
    self.outputLabel = [[UILabel alloc] init];
    self.outputLabel.textAlignment = NSTextAlignmentCenter;
    self.outputLabel.textColor = [UIColor blackColor];
    self.outputLabel.text = @"0";
    [self.view addSubview:self.outputLabel];
    [self.outputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bendingView.mas_bottom).offset(SYRealValue(20));
        make.centerX.mas_equalTo(bendingView.mas_centerX);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

@end
