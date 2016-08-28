//
//  KWCodeItemManager.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/26.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeItemManager.h"

@interface KWCodeItemManager ()

@property (nonatomic, strong) NSMenuItem *mainItem;

@end

@implementation KWCodeItemManager

- (instancetype)initWithMainItemAtPath:(NSString *)path beforeItemNamed:(NSString *)itemName
{
    if (self = [self init]) {
        NSMenu *mainMenu = [NSApp mainMenu];
        NSArray *components = [path componentsSeparatedByString:@"."];
        if (components.count == 0 || components.count > 2) return nil;
        NSMenuItem *level1 = [mainMenu itemWithTitle:components.firstObject];
        if (!level1) {
            NSLog(@"------------------------1");
            level1 = [[NSMenuItem alloc] init];
            level1.title = [components firstObject];
            level1.submenu = [[NSMenu alloc] initWithTitle:level1.title];
            NSInteger windowIndex = [mainMenu indexOfItemWithTitle:itemName];
            [mainMenu insertItem:level1 atIndex:windowIndex + 1];
            _mainItem = level1;
        } else {
            if (components.count == 1) {
                _mainItem = level1;
                NSLog(@"------------------------2");
                return self;
            }
            NSMenuItem *level2 = [[NSMenuItem alloc] init];
            level2.title = [components lastObject];
            level2.submenu = [[NSMenu alloc] initWithTitle:level2.title];
            NSInteger windowIndex = [level1.submenu indexOfItemWithTitle:itemName];
            [level1.submenu insertItem:level2 atIndex:windowIndex + 1];
            _mainItem = level2;
            NSLog(@"------------------------3");
        }
    }
    return  self;
}

- (NSMenuItem *)addItemWithTitle:(NSString *)title action:(SEL)action target:(id)target
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
    if (target) {
        [item setTarget:target];
    }
    [self.mainItem.submenu addItem:item];
    return item;
}
@end
