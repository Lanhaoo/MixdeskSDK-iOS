//
//  MXFileDownloadCellModel.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/4/6.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXCellModelProtocol.h"

@class MXFileDownloadMessage;
typedef NS_ENUM(NSUInteger, MXFileDownloadStatus) {
    MXFileDownloadStatusNotDownloaded = 0,
    MXFileDownloadStatusDownloading,
    MXFileDownloadStatusDownloadComplete,
};

@interface MXFileDownloadCellModel : NSObject <MXCellModelProtocol>

- (id)initCellModelWithMessage:(MXFileDownloadMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MXCellModelDelegate>)delegator;

#pragma mark - data
@property (nonatomic, strong) id file;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, strong) UIImage *avartarImage;
@property (nonatomic, assign) MXFileDownloadStatus fileDownloadStatus;
@property (nonatomic, copy) NSString *timeBeforeExpire;
@property (nonatomic, assign) BOOL isExpired;

#pragma mark - registered callbacks
@property (nonatomic, copy) void(^fileDownloadStatusChanged)(MXFileDownloadStatus);
@property (nonatomic, copy) void(^needsToUpdateUI)(void);
@property (nonatomic, copy) void(^avatarLoaded)(UIImage *);
@property (nonatomic, copy) CGFloat(^cellHeight)(void);

#pragma mark - actions
- (void)startDownloadWitchProcess:(void(^)(CGFloat))block;
- (void)cancelDownload;
- (void)openFile:(id)sender;
- (void)previewFileFromController:(UIViewController *)controller;

@end
