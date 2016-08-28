//
//  KWProgressAlert.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWProgressAlert.h"
#import "KWProgressView.h"

@interface KWProgressAlert ()

@property (strong) KWProgressView *progressView;

@property (nonatomic, assign) NSInteger value;

@property (weak) NSButton *button;

@property (nonatomic, copy) void(^cancelAction)(NSInteger index);

@property (nonatomic, assign) NSInteger total;

@property (nonatomic, strong) NSMutableDictionary *titles;

@property (nonatomic, assign) KWProgressAlertState state;

@end

@implementation KWProgressAlert

- (instancetype)initWithTotal:(NSInteger)total
{
    if (self = [self init]) {
        self.total = total;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _progressView = [KWProgressView commonView];
        _button = [self addButtonWithTitle:@"取消"];
        self.accessoryView = _progressView;
        _state = KWProgressAlertStateWaiting;
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(KWProgressAlertState)state
{
    self.titles[@(state)] = title ?: @"进行中";
}

- (void)setTotal:(NSInteger)total
{
    _total = total;
    [self.progressView updateWithTotal:total andProgress:self.value];
}

- (void)updateProgressToValue:(NSInteger)value
{
    self.value = value;
    if (value > self.total) {
        self.state = KWProgressAlertStateComplete;
        _button.title = @"完成";
        value = self.total;
    }
    [self.progressView updateWithTotal:self.total andProgress:value];
}

- (void)cancel
{
    if (self.value < self.total) {
        [self.window close];
        if (self.cancelAction) {
            self.cancelAction(self.value);
        }
    }
}

- (void)finish
{
    if (self.value >= self.total) {
        [self.window close];
    }
}

- (void)setButtonAction:(void (^)(NSInteger))action
{
    _cancelAction = action;

}

- (void)showOnWindow:(NSWindow *)window
{
    self.state = KWProgressAlertStateProgress;
    __weak typeof(self) ws = self;
    [self beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        __strong typeof(ws) ss = ws;
        if (returnCode == 1000) {
            if (ss.cancelAction) {
                ss.cancelAction(ss.value);
            }
        }
    }];
}

- (void)setState:(KWProgressAlertState)state
{
    _state = state;
    self.messageText = self.titles[@(state)] ? : @"";
}

- (NSMutableDictionary *)titles
{
    if (!_titles) {
        _titles = [@{} mutableCopy];
    }
    return _titles;
}
@end
