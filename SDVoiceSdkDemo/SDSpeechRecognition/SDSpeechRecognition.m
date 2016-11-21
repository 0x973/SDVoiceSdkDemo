//
//  SDSpeechRecognition.m
//
//  Created by Any on 20/11/2016.
//  Copyright © 2016 Any. All rights reserved.
//

#import "SDSpeechRecognition.h"

@interface  SDSpeechRecognition() <IFlyRecognizerViewDelegate> {
    IFlyRecognizerView *_iFlyRecognizerView;
}

@end

@implementation SDSpeechRecognition

+(void)initializeWithAppId:(NSString *)appid Timeout:(NSString *)timeout {
    //通过appid连接讯飞语音服务器,appid传入即可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@, timeout=%@", appid, timeout];
    //启动前 需确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
}

-(void)setUp:(CGPoint)point asrAudioFileName:(NSString *)audioFileName punctuation:(int)punctuation AutoRotate:(BOOL)AutoRotate{
    //初始化语音识别控件
    _iFlyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:point];
    //设置代理对象
    _iFlyRecognizerView.delegate = self;
    //设置应用模式
    [_iFlyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    //保存录音文件名 不需要则设置为nil,默认目录为documents
    [_iFlyRecognizerView setParameter:audioFileName forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    //横竖屏自适应是否开启
    [_iFlyRecognizerView setAutoRotate:AutoRotate];
    switch (punctuation) {
        case 0:
            //标点文本设置  0为关闭自动加标点   1为开启
            [_iFlyRecognizerView setParameter:@"0" forKey:[IFlySpeechConstant ASR_PTT]];
            break;
        case  1:
            //标点文本设置  0为关闭自动加标点   1为开启
            [_iFlyRecognizerView setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
            break;
        default:
            //标点文本设置  0为关闭自动加标点   1为开启
            [_iFlyRecognizerView setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
            break;
    }
}

-(void)start {
    [_iFlyRecognizerView start];
}

-(void)cancel {
    [_iFlyRecognizerView cancel];
}

-(void)showLogcat:(BOOL)showLogcat {
    [IFlySetting showLogcat:showLogcat];
}

//识别会话错误返回代理
- (void)onError:(IFlySpeechError *)error {
    NSLog(@"识别状态:%@",error.errorDesc);
    //    switch (error.errorCode) {
    //        case 20001:
    //            NSLog(@"无有效的网络连接");
    //            break;
    //        case 20002:
    //            NSLog(@"网络连接超时");
    //            break;
    //        case 20003:
    //            NSLog(@"网络异常");
    //            break;
    //        case 20004:
    //            NSLog(@"无有效的结果");
    //            break;
    //        case 20005:
    //            NSLog(@"无匹配结果");
    //            break;
    //        case 20006:
    //            NSLog(@"录音失败");
    //            break;
    //        case 20007:
    //            NSLog(@"未检测到语音");
    //            break;
    //        case 20008:
    //            NSLog(@"音频输入超时");
    //            break;
    //        case 20009:
    //            NSLog(@"无效的文本输入");
    //            break;
    //        case 20010:
    //            NSLog(@"文件读写失败");
    //            break;
    //        case 20011:
    //            NSLog(@"音频播放失败");
    //            break;
    //        case 20012:
    //            NSLog(@"无效的参数");
    //            break;
    //        case 20013:
    //            NSLog(@"文本溢出");
    //            break;
    //        case 20014:
    //            NSLog(@"无效数据");
    //            break;
    //        case 20015:
    //            NSLog(@"用户未登录");
    //            break;
    //        case 20016:
    //            NSLog(@"无效授权");
    //            break;
    //        case 20017:
    //            NSLog(@"被异常打断");
    //            break;
    //        case 20018:
    //            NSLog(@"版本过低");
    //            break;
    //        case 20019:
    //            NSLog(@"未知错误");
    //            break;
    //        default:
    //            break;
    //    }
}

//识别完成返回结果 (代理方法不要直接调用)
-(void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast {
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = resultArray[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@", key];
    }
    NSString *resultFromJson = [self stringFromJson:resultString];
    //    NSLog(@"%@", resultFromJson);
    if (self.resultStr) {
        self.resultStr(resultFromJson);
    }
}


/**
 解析命令词返回的结果
 ****/
- (NSString*)stringFromAsr:(NSString*)params {
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSString *inputString = nil;
    NSArray *array = [params componentsSeparatedByString:@"\n"];
    for (int  index = 0; index < array.count; index++) {
        NSRange range;
        NSString *line = [array objectAtIndex:index];
        NSRange idRange = [line rangeOfString:@"id="];
        NSRange nameRange = [line rangeOfString:@"name="];
        NSRange confidenceRange = [line rangeOfString:@"confidence="];
        NSRange grammarRange = [line rangeOfString:@" grammar="];
        NSRange inputRange = [line rangeOfString:@"input="];
        if (confidenceRange.length == 0 || grammarRange.length == 0 || inputRange.length == 0 ) {
            continue;
        }
        //check nomatch
        if (idRange.length!=0) {
            NSUInteger idPosX = idRange.location + idRange.length;
            NSUInteger idLength = nameRange.location - idPosX;
            range = NSMakeRange(idPosX,idLength);
            NSString *idValue = [[line substringWithRange:range]stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            if ([idValue isEqualToString:@"nomatch"]) {
                return @"";
            }
        }
        //Get Confidence Value
        NSUInteger confidencePosX = confidenceRange.location + confidenceRange.length;
        NSUInteger confidenceLength = grammarRange.location - confidencePosX;
        range = NSMakeRange(confidencePosX,confidenceLength);
        NSString *score = [line substringWithRange:range];
        NSUInteger inputStringPosX = inputRange.location + inputRange.length;
        NSUInteger inputStringLength = line.length - inputStringPosX;
        range = NSMakeRange(inputStringPosX , inputStringLength);
        inputString = [line substringWithRange:range];
        [resultString appendFormat:@"%@ 置信度%@\n",inputString, score];
    }
    return resultString;
}

/**
 解析听写json格式的数据
 params例如：
 {"sn":1,"ls":true,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"w":"白日","sc":0}]},{"bg":0,"cw":[{"w":"依山","sc":0}]},{"bg":0,"cw":[{"w":"尽","sc":0}]},{"bg":0,"cw":[{"w":"黄河入海流","sc":0}]},{"bg":0,"cw":[{"w":"。","sc":0}]}]}
 ****/
- (NSString *)stringFromJson:(NSString*)params {
    if (params == NULL) {
        return nil;
    }
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    //返回的格式必须为utf8的,否则发生未知错误
    NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:[params dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    if (resultDic!= nil) {
        NSArray *wordArray = [resultDic objectForKey:@"ws"];
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }
    }
    return tempStr;
}


/**
 解析语法识别返回的结果
 ****/
- (NSString *)stringFromABNFJson:(NSString*)params {
    if (params == NULL) {
        return nil;
    }
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:[params dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    NSArray *wordArray = [resultDic objectForKey:@"ws"];
    for (int i = 0; i < [wordArray count]; i++) {
        NSDictionary *wsDic = [wordArray objectAtIndex: i];
        NSArray *cwArray = [wsDic objectForKey:@"cw"];
        for (int j = 0; j < [cwArray count]; j++) {
            NSDictionary *wDic = [cwArray objectAtIndex:j];
            NSString *str = [wDic objectForKey:@"w"];
            NSString *score = [wDic objectForKey:@"sc"];
            [tempStr appendString: str];
            [tempStr appendFormat:@" 置信度:%@",score];
            [tempStr appendString: @"\n"];
        }
    }
    return tempStr;
}


@end
