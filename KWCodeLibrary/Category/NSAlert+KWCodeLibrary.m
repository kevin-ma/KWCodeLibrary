//
//  NSAlert+KWCodeLibrary.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "NSAlert+KWCodeLibrary.h"

@implementation NSAlert (KWCodeLibrary)

+ (void)alertNoticeWithTitle:(NSString *)title message:(NSString *)message
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:title];
    if (message != nil) {
        [alert setInformativeText:message];
    }
    [alert runModal];
}

+ (void)sheetNoticeOnWindow:(NSWindow *)window withTitle:(NSString *)title message:(NSString *)message positiveButton:(NSString *)positive negativeButton:(NSString *)negative action:(void(^)(BOOL positive))action
{
    NSAlert *alert = [[NSAlert alloc] init];
    if (title) {
        [alert setMessageText:title];
    }
    if (message) {
        [alert setInformativeText:message];
    }
    [alert addButtonWithTitle:positive];
    [alert addButtonWithTitle:negative];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case 1000:
            {
                action(YES);
            }
            break;
            case 1001:
            {
                action(NO);
            }
            break;
            default:
                break;
        }
    }];

}

+ (void)alertNoticeOnWindow:(NSWindow *)window withTitle:(NSString *)title message:(NSString *)message positiveButton:(NSString *)positive negativeButton:(NSString *)negative action:(void(^)(BOOL positive))action
{
    NSAlert *alert = [[NSAlert alloc] init];
    if (title) {
        [alert setMessageText:title];
    }
    if (message) {
        [alert setInformativeText:message];
    }
    [alert addButtonWithTitle:positive];
    [alert addButtonWithTitle:negative];
    switch ([alert runModal]) {
        case 1000:
            action(YES);
            break;
        case 1001:
            action(NO);
            break;
        default:
            break;
    }
}
@end
