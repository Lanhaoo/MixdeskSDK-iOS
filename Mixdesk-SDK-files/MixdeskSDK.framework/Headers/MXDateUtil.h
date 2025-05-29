//
//  MXDate.h
//  MixdeskSDK
//
//  Created by dingnan on 15/10/24.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXDateUtil : NSObject

+ (NSString *)iso8601StringFromUTCDate:(NSDate *)date;
+ (NSDate *)convertToUtcDateFromUTCDateString:(NSString *)dateString;

+ (NSDate *)convertToLoaclDateFromUTCDate:(NSDate *)anyDate;
+ (NSDate *)convertToUTCDateFromLocalDate:(NSDate *)fromDate;

+ (BOOL)isValidISO8601Format:(NSString *)dateString;
+ (NSDate *)convertISODateFromDateString:(NSString *)dateString;

@end
