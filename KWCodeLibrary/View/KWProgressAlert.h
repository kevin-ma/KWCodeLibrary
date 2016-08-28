//
//  KWProgressAlert.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, KWProgressAlertState) {
    KWProgressAlertStateWaiting,
    KWProgressAlertStateProgress,
    KWProgressAlertStateComplete,
};

@interface KWProgressAlert : NSAlert

- (instancetype)initWithTotal:(NSInteger)total;

- (void)setTitle:(NSString *)title forState:(KWProgressAlertState)state;

// default NO;
- (void)setButtonAction:(void(^)(NSInteger finished))action;

- (void)updateProgressToValue:(NSInteger)value;

- (void)cancel;

- (void)showOnWindow:(NSWindow *)window;

- (void)finish;

@end
