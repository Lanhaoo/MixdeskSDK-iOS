//
//  MXDateFormatterUtil.m
//  MXChatViewControllerDemo
//
//  Created by Injoy on 15/11/17.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MXDateFormatterUtil.h"

//#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation MXDateFormatterUtil

#pragma mark - Initialization

+ (MXDateFormatterUtil *)sharedFormatter
{
    static MXDateFormatterUtil *_sharedFormatter = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [[MXDateFormatterUtil alloc] init];
    });
    
    return _sharedFormatter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDoesRelativeDateFormatting:YES];
    }
    return self;
}

- (void)dealloc
{
    _dateFormatter = nil;
}

#pragma mark - Formatter

- (NSString *)mixdeskStyleDateForDate:(NSDate *)date
{
    if ([MXDateFormatterUtil dateYearFromDate:date] == [MXDateFormatterUtil dateYearFromDate:[NSDate date]]) {
        NSInteger days = [MXDateFormatterUtil dateDayFromDate:[NSDate date]] - [MXDateFormatterUtil dateDayFromDate:date];
        if (days <= 1) {
            //昨天内
            return [self timestampForDate:date];
        }else if (days <= 6){
            //一星期内
            return [NSString stringWithFormat:@"%@ %@", [self weekForDate:date], [self timeForDate:date]];
        }else{
            //年内
            return [self timestampForDate:date];
        }
    }else{
        //去年以前
        return [self timestampForDate:date];
    }
}

- (NSString *)mixdeskSplitLineDateForDate:(NSDate *)date
{
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return [self.dateFormatter stringFromDate:date];;
}

- (NSString *)timestampForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)timeForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)relativeDateForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)weekForDate:(NSDate *)date
{
    self.dateFormatter.dateFormat = @"cccc";
    return [self.dateFormatter stringFromDate:date];
}

+ (NSInteger) dateYearFromDate:(NSDate *)date{
//    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
    NSDateComponents *components = [self obtainComponentsWithDate:date];
    return components.year;
}

+ (NSInteger) dateDayFromDate:(NSDate *)date{
//    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
//    return components.day;
    NSDateComponents *components = [self obtainComponentsWithDate:date];
    return components.day;
}
#pragma mark - 这一部分警告 是因为用的枚举变量 在ios8时被弃用
+ (NSDateComponents *)obtainComponentsWithDate:(NSDate *)date{
    
    return [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
}
@end
