//
//  KWCodeLibrary.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import "KWCodeLibrarySettingController.h"

@interface KWCodeLibrary : NSObject

+ (instancetype)sharedPlugin;

+ (BOOL)shouldLoadPlugin;

- (void)setCodeEnableForDisplay:(BOOL)enable;

@property (nonatomic, strong, readonly) NSBundle* bundle;

@property (nonatomic, strong) KWCodeLibrarySettingController *settingWindow;

@end