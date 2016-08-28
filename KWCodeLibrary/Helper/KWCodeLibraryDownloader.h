//
//  KWCodeLibraryDownloader.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/23.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KWDownloadCompletion)(NSString *path, NSError *error);
typedef void(^KWDataDownloadCompletion)(NSData *data, NSError *error);
typedef void(^KWDownloadProgress)(CGFloat progress);

@interface KWCodeLibraryDownloader : NSObject<NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

+ (NSString*)CodeSnippetRepoPath;

+ (void)setCodeSnippetRepoPath:(NSString*)path;

+ (void)resetCodeSnippetRepoPath;

- (void)downloadCodeSnippetListWithCompletion:(KWDownloadCompletion)completion;
- (void)downloadFileFromPath:(NSString *)remotePath
                    progress:(KWDownloadProgress)progress
                  completion:(KWDataDownloadCompletion)completion;


@end
