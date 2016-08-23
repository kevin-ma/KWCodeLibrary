//
//  DVTSourceTextView+KWCodeLibrary.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "DVTSourceTextView+KWCodeLibrary.h"

@implementation DVTSourceTextView (KWCodeLibrary)

+ (void)load
{
    MethodSwizzle(self,
                  @selector(shouldAutoCompleteAtLocation:),
                  @selector(kevin_shouldAutoCompleteAtLocation:));
}

- (BOOL)kevin_shouldAutoCompleteAtLocation:(unsigned long long)arg1
{
    BOOL shouldAutoComplete = [self kevin_shouldAutoCompleteAtLocation:arg1];
    NSLog(@"makaiwen");
    if (!shouldAutoComplete) {
        @try {
            //Ensure that image autocomplete automatically pops up when you type imageNamed:
            //Search backwards from the current line
            NSRange range = NSMakeRange(0, arg1);
            NSString *string = [[self textStorage] string];
            NSRange newlineRange = [string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:range];
            NSString *line = string;
            
            if (newlineRange.location != NSNotFound) {
                NSRange lineRange = NSMakeRange(newlineRange.location, arg1 - newlineRange.location);
                
                if (lineRange.location < [line length] && NSMaxRange(lineRange) < [line length]) {
                    line = [string substringWithRange:lineRange];
                }
            }
            
            if ([line isEqualToString:@"\n"]) {
                line = @"makaiwen.com";
            }
            if ([line hasPrefix:@"makaiwen"]) {
                shouldAutoComplete = YES;
            }
        } @catch (NSException *exception) {
        }
    }
    
    return shouldAutoComplete;
}

@end
