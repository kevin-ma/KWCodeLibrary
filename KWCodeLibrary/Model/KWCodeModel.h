//
//  KWCodeModel.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/15.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWCodeLibraryIndexCompletionItem.h"

@interface KWCodeModel : KWCodeLibraryIndexCompletionItem

@property (copy) NSString *title;

@property (copy) NSString *shortcut;

@property (copy) NSString *summary;

@property (copy) NSString *snippet;

@property (copy, readonly) NSString *showTipText;

- (instancetype)initWithTitle:(NSString *)title shortcut:(NSString *)shortcut summary:(NSString *)summary snippet:(NSString *)snippet;

+ (NSMutableArray *)modelsWithKeyValues:(NSArray *)keyValues;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (NSArray *)convertModelsToKeyValues:(NSArray *)models;

@end

