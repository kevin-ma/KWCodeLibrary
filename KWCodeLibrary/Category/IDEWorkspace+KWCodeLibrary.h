//
//  IDEWorkspace+KWCodeLibrary.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "IDEWorkspace.h"

@interface IDEWorkspace (KWCodeLibrary)

- (NSString *)currentProjectFolder;

- (NSArray *)defaultScanHeaderDirs;

- (NSArray *)SDKDirs;

- (NSString *)xcprojFile;

@end
