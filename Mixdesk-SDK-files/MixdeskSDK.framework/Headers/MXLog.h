//
//  MXLog.h
//  MixdeskSDK
//
//  Created by ian luo on 16/6/1.
//  Copyright © 2016年 Mixdesk Inc. All rights reserved.
//


#ifndef MXLog.h
#define MXLog.h

#endif /* MXLog.h */

static BOOL MXIsLogEnabled = NO; //发布时默认关闭NO
#define FILENAME [[[NSString alloc] initWithUTF8String:__FILE__] lastPathComponent]

#define MXInfo(str, ...) {\
if(MXIsLogEnabled){\
NSLog(@"Mixdesk [%@,%d]↓↓", FILENAME, __LINE__); \
NSLog(str, ##__VA_ARGS__);\
}\
}

#define MXError(str, ...){\
if(MXIsLogEnabled){\
NSLog(@"Mixdesk [*ERROR*][%@,%d]☟☟", FILENAME, __LINE__); \
NSLog(str, ##__VA_ARGS__);\
}\
}
