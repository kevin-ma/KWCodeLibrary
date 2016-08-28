//
//  KWXcodeCodeSnippetHandler.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWXcodeCodeSnippetHandler.h"
#import "KWCodeModel.h"
#import "KWCodeManager.h"

@interface KWXcodeCodeSnippetHandler ()

@property (nonatomic, copy) NSString *fileDir;

@end

@implementation KWXcodeCodeSnippetHandler

+ (instancetype)handler
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (BOOL)hasCustomCodeSnippet
{
    return [[self handler] hasCustomCodeSnippet];
}

+ (NSArray *)exportAllWithError:(NSError *__autoreleasing *)error
{
    return [[self handler] exportAllWithError:error];
}

+ (void)clean
{
    [[self handler] clean];
}


# pragma mark - private | 赤羽

- (BOOL)hasCustomCodeSnippet
{
    if (!self.fileDir) {
        return NO;
    } else {
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL exist = [manager fileExistsAtPath:self.fileDir];
        if (exist) {
            NSError *error;
            NSArray *files = [manager contentsOfDirectoryAtPath:self.fileDir error:&error];
            if (error) {
                return NO;
            } else {
                if (files && files.count) {
                    return YES;
                }
            }
        } else {
            return NO;
        }
    }
    return NO;
}

- (NSArray *)exportAllWithError:(NSError *__autoreleasing *)error
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager contentsOfDirectoryAtPath:self.fileDir error:error];

    NSMutableArray *tempArr = [@[] mutableCopy];
    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dict = [self dictWithXcodeCodeSnippetFile:[self.fileDir stringByAppendingPathComponent:obj]];
        KWCodeModel *model = [KWCodeModel modelWithDictionary:dict];
        [tempArr addObject:model];
    }];
    return [tempArr copy];
}

- (void)clean
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager contentsOfDirectoryAtPath:self.fileDir error:&error];
    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [self.fileDir stringByAppendingPathComponent:obj];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }];
}

- (NSString *)fileDir
{
    if (!_fileDir) {
        NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
        __block NSString *path = nil;
        [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasSuffix:@"Library"]) {
                path = obj;
                *stop = YES;
            }
        }];
        path = [[[[path stringByAppendingPathComponent:@"Developer"] stringByAppendingPathComponent:@"Xcode"] stringByAppendingPathComponent:@"UserData"] stringByAppendingPathComponent:@"CodeSnippets"];

        _fileDir = path;
    }
    return _fileDir;
}

- (NSDictionary *)dictWithXcodeCodeSnippetFile:(NSString *)file
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
    NSMutableDictionary *temp = [@{} mutableCopy];
    NSString *title = dict[@"IDECodeSnippetTitle"];
    NSString *summary = dict[@"IDECodeSnippetSummary"];
    NSString *shortcut = dict[@"IDECodeSnippetCompletionPrefix"];
    NSString *snippet = dict[@"IDECodeSnippetContents"];
    temp[@"title"] = title.length ? title : @"From Xcode";
    temp[@"summary"] = summary.length ? summary : @"From Xcode";
    temp[@"shortcut"] = shortcut.length ? shortcut : [NSString stringWithFormat:@"xcode_%d",arc4random_uniform(100)];
    temp[@"snippet"] = snippet;
    return [temp copy];
}

@end

