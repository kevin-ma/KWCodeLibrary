//
//  NSAlert+KWCodeLibrary.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAlert (KWCodeLibrary)

+ (void)alertNoticeWithTitle:(NSString *)title message:(NSString *)message;

+ (void)sheetNoticeOnWindow:(NSWindow *)window withTitle:(NSString *)title message:(NSString *)message positiveButton:(NSString *)positive negativeButton:(NSString *)negative action:(void(^)(BOOL positive))action;

+ (void)alertNoticeOnWindow:(NSWindow *)window withTitle:(NSString *)title message:(NSString *)message positiveButton:(NSString *)positive negativeButton:(NSString *)negative action:(void(^)(BOOL positive))action;

@end
