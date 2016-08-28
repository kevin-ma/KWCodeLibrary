//
//  KWProgressView.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWProgressView.h"

@interface KWProgressView ()

@property (strong) NSTextField *progressInfo;
@property (strong) NSProgressIndicator *progressView;

@end

@implementation KWProgressView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self == [super initWithFrame:frameRect]) {
        _progressView = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.width - 100, 24)];
        _progressView.minValue = 0;
        _progressView.doubleValue = 0;
        _progressView.indeterminate = NO;
        [self addSubview:_progressView];
        
        _progressInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(frameRect.size.width - 100 + 5, 0, 80, 24)];
        _progressInfo.editable = NO;
        _progressInfo.bordered = NO;
        _progressInfo.backgroundColor = [NSColor clearColor];
        [self addSubview:_progressInfo];
    }
    return self;
}

+ (instancetype)commonView
{
    return [[self alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
}

- (void)updateWithTotal:(NSInteger)total andProgress:(NSInteger)progress
{
    if (self.progressView.maxValue != total) {
        self.progressView.maxValue = total;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.doubleValue = progress;
        [self.progressView displayIfNeeded];
        self.progressInfo.stringValue = [NSString stringWithFormat:@"%02ld/%02ld",(long)progress,(long)total];
    });
}
@end
