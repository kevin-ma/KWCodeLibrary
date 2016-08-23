//
//  DVTCompletingTextView.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DVTCompletingTextView : NSTextView

- (BOOL)shouldAutoCompleteAtLocation:(unsigned long long)arg1;

@end