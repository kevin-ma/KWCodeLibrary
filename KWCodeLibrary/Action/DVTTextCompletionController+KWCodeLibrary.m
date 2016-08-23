//
//  DVTTextCompletionController+KWCodeLibrary.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "DVTTextCompletionController+KWCodeLibrary.h"
#import "MethodSwizzle.h"

@implementation DVTTextCompletionController (KWCodeLibrary)

+ (void)load
{
    MethodSwizzle(self, @selector(acceptCurrentCompletion), @selector(kevin_acceptCurrentCompletion));
}

- (BOOL)kevin_acceptCurrentCompletion
{
    BOOL success = [self kevin_acceptCurrentCompletion];
    
    if (success) {
        @try {
            NSRange range = [[self textView] selectedRange];
            
            for (NSString *nextClassAndMethod in @[@"kevin",@"makaiwen"]) {
                //If an autocomplete causes imageNamed: to get inserted, remove the token and immediately pop up autocomplete
                if (range.location > [nextClassAndMethod length]) {
                    NSString *insertedString = [[[self textView] string] substringWithRange:NSMakeRange(range.location - [nextClassAndMethod length], [nextClassAndMethod length])];
                    
                    if ([insertedString isEqualToString:nextClassAndMethod]) {
                        [[self textView] insertText:@"" replacementRange:range];
                        [self _showCompletionsAtCursorLocationExplicitly:YES];
                    }
                }
            }
        } @catch (NSException *exception) {
            //I'd rather not crash if Xcode chokes on something
        }
    }
    
    return success;
}


@end
