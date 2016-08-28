//
//  KWCodeManager.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/15.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KWNotFound -1

@interface KWCodeManager : NSObject

+ (instancetype)defaultManager;

- (void)loadData;

- (KWCodeManager *)addModelWithTitle:(NSString *)title shortcut:(NSString *)shortcut summary:(NSString *)summary snippet:(NSString *)snippet;

- (KWCodeManager *)updateModelAtIndex:(NSInteger)index withTitle:(NSString *)title shortcut:(NSString *)shortcut summary:(NSString *)summary snippet:(NSString *)snippet;

- (KWCodeManager *)removeModelAtIndex:(NSInteger)index;

- (KWCodeManager *)removeAll;

- (NSArray *)allModel;

- (void)synchronize;

- (void)importWithFileUrl:(NSURL *)url;

- (void)exportWithFileUrl:(NSURL *)url;

- (void)importFromCodeSnippetWithComplete:(void(^)())complete;

- (NSInteger)indexForModelWithShortcut:(NSString *)shortcut andTitle:(NSString *)title;

@property (assign,getter=isCodeEnable) BOOL codeEnable;

@end
