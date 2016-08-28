//
//  KWXcodeCodeSnippetHandler.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWXcodeCodeSnippetHandler : NSObject

+ (instancetype)handler;

+ (BOOL)hasCustomCodeSnippet;

+ (NSArray *)exportAllWithError:(NSError **)error;

+ (void)clean;

@end
