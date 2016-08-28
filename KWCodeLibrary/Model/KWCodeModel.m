//
//  KWCodeModel.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/15.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeModel.h"
#import <AppKit/AppKit.h>

@interface KWCodeModel ()

@property (copy) NSString *showTipText;

@end

@implementation KWCodeModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.title = dict[@"title"] ? :@"";
        self.shortcut = dict[@"shortcut"] ? :@"";
        self.summary = dict[@"summary"] ? :@"";
        self.snippet = dict[@"snippet"] ? :@"";
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

+ (NSMutableArray *)modelsWithKeyValues:(NSArray *)keyValues
{
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *dict in keyValues) {
        [temp addObject:[self modelWithDictionary:dict]];
    }
    return temp;
}

+ (NSArray *)convertModelsToKeyValues:(NSArray *)models
{
    NSMutableArray *temp = [@[] mutableCopy];
    for (KWCodeModel *model in models) {
        NSDictionary *dict = @{@"title":model.title ?: @"",@"shortcut":model.shortcut ?: @"",@"summary":model.summary ?: @"",@"snippet":model.snippet ?: @""};
        [temp addObject:dict];
    }
    return [temp copy];
}

- (instancetype)initWithTitle:(NSString *)title shortcut:(NSString *)shortcut summary:(NSString *)summary snippet:(NSString *)snippet
{
    if (self = [super init]) {
        self.title = title ? :@"";
        self.shortcut = shortcut ? :@"";
        self.summary = summary ? :@"";
        self.snippet = snippet ? :@"";
    }
    return self;
}

- (NSString *)completionText
{
    return self.snippet;
}

- (NSString *)displayText
{
    return self.showTipText;
}

- (NSAttributedString *)descriptionText
{
    return [[NSAttributedString alloc] initWithString:self.summary attributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:16]}];
}

- (NSString *)name
{   
    return self.shortcut;
}

- (BOOL)isEqual:(KWCodeModel *)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    } else {
        if ([object.shortcut isEqualToString:self.shortcut]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)showTipText
{
    NSString *title = self.title;
    if (!title || title.length == 0) {
        title = @"KWCodeLibrary Code Snippet";
    }
    _showTipText = [NSString stringWithFormat:@"%@ - %@",self.shortcut,self.title];
    return _showTipText;
}
@end
