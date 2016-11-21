//
//  SDSpeechRecognition.h
//
//  Created by Any on 20/11/2016.
//  Copyright © 2016 Any. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iflyMSC/iflyMSC.h>

typedef void(^resultStrBlock)(NSString *);


/**
 * 郑守栋集成讯飞语音SDK的语音转文字 为了更快开发语音转文字相关模块
 */
@interface SDSpeechRecognition : NSObject {
    
}

/**
 * block回调最终返回的结果(会多次调用)用的时候format拼接即可连成完整字符
 */
@property (nonatomic, copy)resultStrBlock resultStr;


/**
 * 必须首先初始化并传入appid 否则将引起崩溃
 * timeout 设置网络连接超时时长
 */
+(void)initializeWithAppId:(NSString *)appid Timeout:(NSString *)timeout;

/**
 * 初始化语音识别控件
 * point 一般为view的中央点
 * audioFileName 录音文件名,如果不保留录音文件设置为nil
 * punctuation 标点文本设置,0为关闭自动加标点,1为开启
 * AutoRotate 横竖屏自适应是否开启 YES or No
 */
-(void)setUp:(CGPoint)point asrAudioFileName:(NSString *)audioFileName punctuation:(int)punctuation AutoRotate:(BOOL)AutoRotate;

/**
 * 开始语音转文字
 */
-(void)start;

/**
 * 取消语音转文字
 */
-(void)cancel;

/**
 * showLogcat设置控制台日志是否打印(发布时候需要关闭打印日志)
 * 建议在服务初始化前调用 注意调用顺序
 */
-(void)showLogcat:(BOOL)showLogcat;

@end
