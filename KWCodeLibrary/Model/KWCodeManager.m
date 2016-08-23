//
//  KWCodeManager.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/15.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeManager.h"
#import "KWCodeModel.h"
#import <AppKit/AppKit.h>
#import "KWCodeLibrary.h"

NSString *const kCodeManagerCodeModelKey = @"kCodeManagerCodeModelKey";
NSString *const kCodeManagerCodeEnableKey = @"kCodeManagerCodeEnableKey";

@interface KWCodeManager ()

@property (strong) NSMutableArray *modelList;

@end

@implementation KWCodeManager

+ (instancetype)defaultManager
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[KWCodeManager alloc] init];
//        [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kCodeManagerCodeModelKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    return _instance;
}

- (NSInteger)indexForModelWithShortcut:(NSString *)shortcut
{
    for (NSInteger i = 0; i < self.modelList.count; i++) {
        KWCodeModel *model = self.modelList[i];
        if ([model.shortcut isEqualToString:shortcut]) {
            return i;
        }
    }
    return -1;
}

- (void)loadData
{
    NSArray *dicts = [[NSUserDefaults standardUserDefaults] objectForKey:kCodeManagerCodeModelKey];
    self.modelList = [KWCodeModel modelsWithKeyValues:dicts];
    if (self.modelList == nil) {
        self.modelList = [@[] mutableCopy];
        
    }
}

- (KWCodeManager *)updateModelAtIndex:(NSInteger)index withTitle:(NSString *)title shortcut:(NSString *)shortcut summary:(NSString *)summary snippet:(NSString *)snippet
{
    if (index >= self.modelList.count) return self;
    KWCodeModel *model = self.modelList[index];
    if (title) {
        model.title = title;
    }
    if (shortcut) {
        model.shortcut = shortcut;
    }
    if (summary) {
        model.summary = summary;
    }
    if (snippet) {
        model.snippet = snippet;
    }
    self.modelList[index] = model;
    return self;
}

- (KWCodeManager *)removeModelAtIndex:(NSInteger)index
{
    if (self.modelList.count > index) {
        [self.modelList removeObjectAtIndex:index];
    }
    return self;
}

- (KWCodeManager *)removeAll
{
    self.modelList = [@[] mutableCopy];
    return self;
}

- (NSArray *)allModel
{
    return self.modelList;
}

- (void)synchronize
{
    [[NSUserDefaults standardUserDefaults] setObject:[KWCodeModel convertModelsToKeyValues:self.modelList] forKey:kCodeManagerCodeModelKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (KWCodeManager *)addModelWithTitle:(NSString *)title shortcut:(NSString *)shortcut summary:(NSString *)summary snippet:(NSString *)snippet
{
    for (KWCodeModel *model in self.modelList) {
        if ([model.shortcut isEqualToString:shortcut]) {
            return self;
        }
    }
    KWCodeModel *model = [[KWCodeModel alloc] initWithTitle:title shortcut:shortcut summary:summary snippet:snippet];
    [self.modelList addObject:model];
    return self;
}

- (void)setCodeEnable:(BOOL)codeEnable
{
    [[NSUserDefaults standardUserDefaults] setBool:codeEnable forKey:kCodeManagerCodeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isCodeEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCodeManagerCodeEnableKey];
}

- (void)importWithFileUrl:(NSURL *)url
{
    NSArray *list = [NSArray arrayWithContentsOfURL:url];
    if (!list) {
        [self alertNotice:@"Error" info:@"Unsupported File"];
        return;
    }
    BOOL override = NO;
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *dict in list) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            [self alertNotice:@"Error" info:@"Unsupported File"];
            return;
        } else {
            if (!dict[@"shortcut"] || !dict[@"snippet"]) {
                [self alertNotice:@"Error" info:@"Unsupported File"];
                return;
            }
            NSInteger index = [self indexForModelWithShortcut:dict[@"shortcut"]];
            if (index != -1) {
                [self removeModelAtIndex:index];
                override = YES;
            }
            [temp addObject:[KWCodeModel modelWithDictionary:dict]];
        }
    }
    [self.modelList addObjectsFromArray:temp];
    if (override) {
        [self alertNotice:@"Success" info:@"has override which exist"];
    } else {
        [self alertNotice:@"Success" info:nil];
    }
    [self synchronize];
}

- (void)exportWithFileUrl:(NSURL *)url
{
    NSString *path = [url path];
    NSArray *dicts = [[NSUserDefaults standardUserDefaults] objectForKey:kCodeManagerCodeModelKey];
    [dicts writeToFile:path atomically:YES];
}

- (void)importFromCodeSnippetWithComplete:(void (^)(NSString *, NSArray *))complete
{
    NSError *error;
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
    __block NSString *path = nil;
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasSuffix:@"Library"]) {
            path = obj;
            *stop = YES;
        }
    }];
    path = [path stringByAppendingPathComponent:@"Developer"];
    path = [path stringByAppendingPathComponent:@"Xcode"];
    path = [path stringByAppendingPathComponent:@"UserData"];
    path = [path stringByAppendingPathComponent:@"CodeSnippets"];

    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:path];
    if (exist) {
        NSArray *files = [manager contentsOfDirectoryAtPath:path error:&error];
        if (error) {
            [self alertNotice:@"Error" info:error.localizedDescription];
        } else {
            // files
            __block BOOL override = NO;
            NSMutableArray *tempArr = [@[] mutableCopy];
            [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dict = [self dictWithXcodeCodeSnippetFile:[path stringByAppendingPathComponent:obj]];
                KWCodeModel *model = [KWCodeModel modelWithDictionary:dict];
                NSInteger index = [self indexForModelWithShortcut:dict[@"shortcut"]];
                if (index != -1) {
                    [self removeModelAtIndex:index];
                    override = YES;
                }
                [tempArr addObject:model];
            }];
            [self.modelList addObjectsFromArray:tempArr];
            [self synchronize];
            if (override) {
                [self alertNotice:@"Success" info:@"has override which exist"];
            } else {
                [self alertNotice:@"Success" info:nil];
            }
            if (complete) {
                complete(path,files);
            }
        }
    } else {
        [self alertNotice:@"Warning" info:@"you don't have code snippet in xcode"];
    }
}

- (NSDictionary *)dictWithXcodeCodeSnippetFile:(NSString *)file
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
    NSMutableDictionary *temp = [@{} mutableCopy];
    temp[@"title"] = dict[@"IDECodeSnippetTitle"];
    temp[@"summary"] = dict[@"IDECodeSnippetSummary"];
    temp[@"shortcut"] = dict[@"IDECodeSnippetCompletionPrefix"];
    temp[@"snippet"] = dict[@"IDECodeSnippetContents"];
    return [temp copy];
}

- (void)alertNotice:(NSString *)string info:(NSString *)info
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:string];
    if (info != nil) {
        [alert setInformativeText:info];
    }
    [alert runModal];
}
@end
