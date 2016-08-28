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
#import "KWXcodeCodeSnippetHandler.h"
#import "KWProgressAlert.h"
#import "NSAlert+KWCodeLibrary.h"

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

- (NSInteger)indexForModelWithShortcut:(NSString *)shortcut andTitle:(NSString *)title
{
    for (NSInteger i = 0; i < self.modelList.count; i++) {
        KWCodeModel *model = self.modelList[i];
        if ([model.shortcut isEqualToString:shortcut] && [model.title isEqualToString:title]) {
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
        [NSAlert alertNoticeWithTitle:@"导入失败" message:@"未知文件类型，请选择“plist”类型文件"];
        return;
    }
    BOOL override = NO;
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *dict in list) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            [NSAlert alertNoticeWithTitle:@"导入失败" message:@"文件格式错误，文件内容无法解析"];
            return;
        } else {
            if (!dict[@"shortcut"] || !dict[@"snippet"] || !dict[@"snippet"]) {
                [NSAlert alertNoticeWithTitle:@"导入失败" message:@"文件格式错误，文件内容无法解析"];
                return;
            }
            NSInteger index = [self indexForModelWithShortcut:dict[@"shortcut"] andTitle:dict[@"title"]];
            if (index != -1) {
                [self removeModelAtIndex:index];
                override = YES;
            }
            [temp addObject:[KWCodeModel modelWithDictionary:dict]];
        }
    }
    [self.modelList addObjectsFromArray:temp];
    if (override) {
        [NSAlert alertNoticeWithTitle:@"已导入完成"  message:@"已导入完成，并且替换重复数据"];
    } else {
        [NSAlert alertNoticeWithTitle:@"已导入完成"  message:nil];
    }
    [self synchronize];
}

- (void)exportWithFileUrl:(NSURL *)url
{
    NSString *path = [url path];
    NSArray *dicts = [[NSUserDefaults standardUserDefaults] objectForKey:kCodeManagerCodeModelKey];
    [dicts writeToFile:path atomically:YES];
}

- (void)importFromCodeSnippetWithComplete:(void (^)())complete
{
    NSError *error;
    NSArray * array = [KWXcodeCodeSnippetHandler exportAllWithError:&error];
    if (error) {
        [NSAlert alertNoticeWithTitle:@"未能完成导入" message:error.localizedDescription];
        return;
    }
    KWProgressAlert *alert = [[KWProgressAlert alloc] initWithTotal:array.count];
    [alert setTitle:@"正在从 Xcode Code Snippet 导入" forState:(KWProgressAlertStateProgress)];
    [alert setTitle:@"已完成导入" forState:(KWProgressAlertStateProgress)];

    [alert showOnWindow:[KWCodeLibrary sharedPlugin].settingWindow.window];
    [alert setButtonAction:^(NSInteger finished) {
        
        
    }];
    [alert updateProgressToValue:0];
    NSMutableArray *tempArr = [@[] mutableCopy];
    [self importModelFromList:array toList:tempArr atIndex:0 progressView:alert complete:complete];
}


- (void)importModelFromList:(NSArray *)fromList toList:(NSMutableArray *)toList atIndex:(NSInteger)idx progressView:(KWProgressAlert *)progressView complete:(void (^)())complete
{
    if (fromList.count <= idx) {
        [self.modelList addObjectsFromArray:toList];
        [self synchronize];
        [progressView updateProgressToValue:idx + 1];
        if (complete) {
            complete();
        }
        [NSAlert alertNoticeOnWindow:[KWCodeLibrary sharedPlugin].settingWindow.window withTitle:@"是否清空 Xcode Code Snippet ？" message:@"Xcode Code Snippet 已全部导入到 KWCodeLibrary 中，是否清空 Xcode Code Snippet？" positiveButton:@"清空" negativeButton:@"暂不清空" action:^(BOOL positive) {
            if (positive) {
                [KWXcodeCodeSnippetHandler clean];
                [NSAlert alertNoticeWithTitle:@"已清理完毕" message:@"已清空 Xcode Code Snippet,重启后生效"];
            }
            [progressView finish];
        }];
        return;
    }
    KWCodeModel *model = fromList[idx];
    NSInteger index = [self indexForModelWithShortcut:model.shortcut andTitle:model.title];
    if (index != KWNotFound) {
        NSString *title = [NSString stringWithFormat:@"已存在 %@ ",model.title];
        NSString *msg = [NSString stringWithFormat:@"已存在 %@ ，是否覆盖？如果不想覆盖请选择“跳过”",model.title];
        __weak typeof(self) ws = self;
        [NSAlert alertNoticeOnWindow:[KWCodeLibrary sharedPlugin].settingWindow.window withTitle:title message:msg positiveButton:@"覆盖" negativeButton:@"跳过" action:^(BOOL positive) {
            __strong typeof(ws) ss = ws;
            if (positive) {
                [ss removeModelAtIndex:index];
                [toList addObject:model];
            }
            [progressView updateProgressToValue:idx];
            [ss importModelFromList:fromList toList:toList atIndex:idx + 1 progressView:progressView complete:complete];
        }];
    } else{
        [toList addObject:model];
        [progressView updateProgressToValue:idx];
        [self importModelFromList:fromList toList:toList atIndex:idx + 1 progressView:progressView complete:complete];
    }
}
@end
