//
//  NSString+MXRegular.m
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "NSString+MXRegular.h"

@implementation NSString (MXRegular)

- (BOOL)mx_match:(NSString *)pattern
{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    return results.count > 0;
}

- (BOOL)mx_isQQ
{
    return [self mx_match:@"^[1-9]\\d{4,10}$"];
}

- (BOOL)mx_isPhoneNumber
{
    return [self mx_match:@"^1[35789]\\d{9}$"];
}

- (BOOL)mx_isTelNumber
{
    return [self mx_match:@"^((0\\d{2,3}-\\d{7,8})|(1[345789]\\d{9}))$"];
}

- (NSString *)mx_textContent
{
    NSString *resultContent = self;
    resultContent = [resultContent stringByReplacingOccurrencesOfString:@"<[^>]+>\\s+(?=<)|<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange (0, resultContent.length)];
    return resultContent;
}


@end
