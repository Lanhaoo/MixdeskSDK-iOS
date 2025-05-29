//
//  MXFileDownloadCellModel.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/4/6.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXFileDownloadCellModel.h"
#import "MXFileDownloadMessage.h"
#import "MXChatFileUtil.h"
#import "MXFileDownloadCell.h"
#import "MXServiceToViewInterface.h"
#import "MXBundleUtil.h"
#import "MXToast.h"
#import <QuickLook/QuickLook.h>

@interface MXFileDownloadCellModel()<UIDocumentInteractionControllerDelegate, QLPreviewControllerDataSource>

@property (nonatomic, strong) MXFileDownloadMessage *message;
@property (nonatomic, copy) NSString *downloadingURL;

@end

@implementation MXFileDownloadCellModel

- (id)initCellModelWithMessage:(MXFileDownloadMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MXCellModelDelegate>)delegator {
    if (self = [super init]) {
        self.message = message;
        if ([MXChatFileUtil fileExistsAtPath:[self savedFilePath] isDirectory:NO]) {
            self.fileDownloadStatus = MXFileDownloadStatusDownloadComplete;
        }
        self.fileName = message.fileName;
        self.fileSize = [self fileSizeStringWithFileSize:(CGFloat)message.fileSize];
        if (message.expireDate.timeIntervalSinceReferenceDate > [NSDate new].timeIntervalSinceReferenceDate) {
            self.timeBeforeExpire = [NSString stringWithFormat:@"%.1f",(message.expireDate.timeIntervalSinceReferenceDate - [NSDate new].timeIntervalSinceReferenceDate) / 3600];
            self.isExpired = NO;
        } else {
            self.timeBeforeExpire = @"";
            self.isExpired = YES;
        }
        
        __weak typeof(self)wself = self;
        [MXServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:nil completion:^(NSData *mediaData, NSError *error) {
            if (mediaData) {
                __strong typeof (wself) sself = wself;
                sself.avartarImage = [UIImage imageWithData:mediaData];
                if (sself.avatarLoaded) {
                    sself.avatarLoaded(sself.avartarImage);
                }
            }
        }];
    }
    return self;
}

- (NSString *)fileSizeStringWithFileSize:(CGFloat)fileSize {
    NSString *fileSizeString = [NSString stringWithFormat:@"%.1f MB", fileSize / 1024 / 1024];
    
    if (fileSizeString.floatValue < 1) {
        fileSizeString = [NSString stringWithFormat:@"%.1f KB", fileSize / 1024];
    }
    
    if (fileSizeString.floatValue < 1) {
        fileSizeString = [NSString stringWithFormat:@"%.0f B", fileSize];
    }
    
    return fileSizeString;
}

- (void)requestForFileURLComplete:(void(^)(NSString *url))action {
    BOOL isURLReady = NO;
    if ([self.message.filePath length] > 0) {
        isURLReady = YES;
        action(self.message.filePath);
    }
    
    //用于统计
    [MXServiceToViewInterface clientDownloadFileWithMessageId:self.message.messageId conversatioId:self.message.conversationId andCompletion:^(NSString *url, NSError *error) {
        if (!isURLReady) {
            action(url);
        }
    }];
}

- (void)startDownloadWitchProcess:(void(^)(CGFloat process))block {
    
    if (!block) {
        return;
    }
    
    if (self.isExpired) {
        [MXToast showToast:[MXBundleUtil localizedStringForKey:@"file_download_file_is_expired"] duration:2 window:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    self.fileDownloadStatus = MXFileDownloadStatusDownloading;
    if (self.needsToUpdateUI) {
        self.needsToUpdateUI();
    }
    block(0);
    
    [self requestForFileURLComplete:^(NSString *url) {
//        url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        self.downloadingURL = url;
       [MXServiceToViewInterface downloadMediaWithUrlString:url progress:^(float progress) {
           self.fileDownloadStatus = MXFileDownloadStatusDownloading;
           block(progress);
       } completion:^(NSData *mediaData, NSError *error) {
           self.downloadingURL = nil;
           if (!error) {
               self.fileDownloadStatus = MXFileDownloadStatusDownloadComplete;
               self.file = mediaData;
               [self saveFile:mediaData];
               block(100);
           } else {
               [MXToast showToast:[NSString stringWithFormat:@"%@ %@",[MXBundleUtil localizedStringForKey:@"file_download_failed"],error.localizedDescription] duration:2 window:[UIApplication sharedApplication].keyWindow];
               self.fileDownloadStatus = MXFileDownloadStatusNotDownloaded;
               block(-1);
           }
       }];
    }];
}

- (void)cancelDownload {
    [MXToast showToast:[MXBundleUtil localizedStringForKey:@"file_download_canceld"] duration:2 window:[UIApplication sharedApplication].keyWindow];
    [MXServiceToViewInterface cancelDownloadForUrl:self.downloadingURL];
    self.downloadingURL = nil;
    self.fileDownloadStatus = MXFileDownloadStatusNotDownloaded;
    if (self.needsToUpdateUI) {
        self.needsToUpdateUI();
    }
}

- (void)openFile:(UIView *)sender {
    NSURL *url = [NSURL fileURLWithPath:[self savedFilePath]];
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    [interactionController setDelegate:self];
    [interactionController presentOptionsMenuFromRect:CGRectZero inView:sender.superview animated:YES];
}

- (void)previewFileFromController:(UIViewController *)controller {
    QLPreviewController *previewController = [QLPreviewController new];
    previewController.dataSource = self;
    previewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [controller presentViewController:previewController animated:YES completion:nil];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:[self savedFilePath]];
}

#pragma mark - private

- (NSString *)savedFilePath {
    return [DIR_RECEIVED_FILE stringByAppendingString:[self persistenceFileName]];
}

- (void)saveFile:(NSData *)data {
    [MXChatFileUtil saveFileWithName:[self persistenceFileName] data:data];
}

- (NSString *)persistenceFileName {
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",self.message.messageId, self.message.fileName];
    return fileName;
}

#pragma mark - delegate

- (CGFloat)getCellHeight {
    if (self.cellHeight) {
        return self.cellHeight();
    }
    return 80;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (MXChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MXFileDownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.message.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.message.messageId;
}

- (NSString *)getMessageConversionId {
    return self.message.conversionId;
}

- (void)updateCellSendStatus:(MXChatMessageSendStatus)sendStatus {
    self.message.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.message.messageId = messageId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.message.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    if (self.needsToUpdateUI) {
        self.needsToUpdateUI();
    }
}

@end
