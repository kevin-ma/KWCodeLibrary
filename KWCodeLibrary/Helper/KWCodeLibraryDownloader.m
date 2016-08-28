//
//  KWCodeLibraryDownloader.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/23.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeLibraryDownloader.h"

@interface KWCodeLibraryDownloader()
@property (strong, nonatomic) NSMutableDictionary *callbacks;
@property (strong, nonatomic) NSURLSession *urlSession;
@end



@implementation KWCodeLibraryDownloader

NSString *const KW_DEFAULT_REPO_PATH = @"https://raw.githubusercontent.com/kevin-ma/KWCodeLibrary/master/Code/default.plist";
NSString *const KW_REPO_KEY = @"KWRepoPath";
NSString *const KW_PROGRESS = @"progress";
NSString *const KW_COMPLETION = @"completion";

- (id)init
{
    if (self = [super init]) {
        _callbacks = [NSMutableDictionary new];
    }
    return self;
}

- (void)downloadCodeSnippetListWithCompletion:(KWDownloadCompletion)completion
{
    [self downloadFileFromPath:[KWCodeLibraryDownloader CodeSnippetRepoPath] progress:^(CGFloat progress) {
    
    } completion:^(NSData *data, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KWCodeSnippet.plist"];
        [data writeToFile:path atomically:YES];
        completion(path, error);
    }];
}

- (void)downloadFileFromPath:(NSString *)remotePath progress:(KWDownloadProgress)progress completion:(KWDataDownloadCompletion)completion
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:remotePath]];
    NSURLSessionTask *task = [[self urlSession] downloadTaskWithRequest:request];
    
    NSMutableDictionary* callbacks = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (completion)
        callbacks[KW_COMPLETION] = completion;
    if (progress)
        callbacks[KW_PROGRESS] = progress;
    
    self.callbacks[task] = callbacks;
    
    [task resume];
}

#pragma mark - Package Repo

+ (NSString*)CodeSnippetRepoPath
{
    NSString* path = [[NSUserDefaults standardUserDefaults] valueForKey:KW_REPO_KEY];
    if (!path)
        path = KW_DEFAULT_REPO_PATH;
    
    return path;
}

+ (void)resetCodeSnippetRepoPath
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KW_REPO_KEY];
}

+ (void)setCodeSnippetRepoPath:(NSString *)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:KW_REPO_KEY];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    
    KWDataDownloadCompletion completionBlock = self.callbacks[downloadTask][KW_COMPLETION];
    if (completionBlock) {
        completionBlock([NSData dataWithContentsOfURL:location], nil);
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    
    KWDownloadProgress progressBlock = self.callbacks[downloadTask][KW_PROGRESS];
    if (progressBlock) {
        progressBlock(progress);
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{

}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    completionHandler(request);
}


# pragma mark - NSURLSessionTask delegate
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    
}


# pragma mark - Private
- (NSURLSession *)urlSession
{
    if (_urlSession) return _urlSession;
    _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    return _urlSession;
}


@end
