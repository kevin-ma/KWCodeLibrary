//
//  KWCodeItemManager.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/26.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface KWCodeItemManager : NSObject

- (instancetype)initWithMainItemAtPath:(NSString *)path beforeItemNamed:(NSString *)itemName;

- (NSMenuItem *)addItemWithTitle:(NSString *)title action:(SEL)action target:(id)target;
@end
