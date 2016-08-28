//
//  KWCodeLibraryIndexCompletionItem.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeLibraryIndexCompletionItem.h"

@implementation KWCodeLibraryIndexCompletionItem

- (NSString *)name
{
    return @"undefine";
}

- (NSString *)displayType
{
    return @"KWCode";
}

- (void)_fillInTheRest { }

- (double)priority
{
    return 9999;
}

- (NSAttributedString *)descriptionText
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"text info"];
    return str;
}

- (DVTSourceCodeSymbolKind *)symbolKind
{
    return [DVTSourceCodeSymbolKind functionSymbolKind];
}

- (BOOL)notRecommended
{
    return NO;
}

- (NSString *)lowercaseName {
    if (!_lowercaseName) {
        _lowercaseName = [self.name lowercaseString];
    }
    return _lowercaseName;
}

@end
