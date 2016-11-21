//
//  ViewController.m
//  SDVoiceSdkDemo
//
//  Created by Any on 20/11/2016.
//  Copyright © 2016 Any. All rights reserved.
//

#import "ViewController.h"
#import "SDSpeechRecognition.h"


@interface ViewController ()

@end

@implementation ViewController
SDSpeechRecognition *sdSR = nil;
UITextView *mainTextDisplay = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self setSDSpeechRecognition];
}

/**
 * 使用SDSpeechRecognition语音转文字模块开发 只需7行代码~
 */
-(void)setSDSpeechRecognition {
    //初始化对象
    sdSR = [[SDSpeechRecognition alloc]init];
    //关闭日志
    [sdSR showLogcat:NO];
    //进行初始化服务
    [SDSpeechRecognition initializeWithAppId:@"12345" Timeout:@"20000"];
    [sdSR setUp:self.view.center asrAudioFileName:@"SDxfyy" punctuation:1 AutoRotate:YES];
    //Block回调传值
    sdSR.resultStr = ^(NSString *str) {
        NSLog(@"-----------%@",str);
        mainTextDisplay.text = [NSString stringWithFormat:@"%@%@",mainTextDisplay.text,str];
    };
}

/**
 * 设置UI界面
 */
-(void)setUpUI {
    //初始化输入框
    mainTextDisplay = [[UITextView alloc]initWithFrame:CGRectMake(0, 30, 375, 210)];
    mainTextDisplay.backgroundColor = [UIColor lightGrayColor];
    //初始化按钮
    UIButton *startTest = [UIButton buttonWithType:UIButtonTypeSystem];
    [startTest setTitle:@"点击后开始说话" forState:UIControlStateNormal];
    [startTest addTarget:self action:@selector(startTestBtnClick) forControlEvents:UIControlEventTouchUpInside];
    startTest.frame = CGRectMake(133, 397, 108, 30);
    [self.view addSubview:startTest];
    [self.view addSubview:mainTextDisplay];
}

//按钮点击事件
-(void)startTestBtnClick {
    [sdSR start];
}

@end
