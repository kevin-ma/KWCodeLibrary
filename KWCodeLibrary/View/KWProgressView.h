//
//  KWProgressView.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KWProgressView : NSView

+ (instancetype)commonView;

- (void)updateWithTotal:(NSInteger)total andProgress:(NSInteger)progress;

@end
