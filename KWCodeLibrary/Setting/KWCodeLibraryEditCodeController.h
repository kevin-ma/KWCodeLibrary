//
//  KWCodeLibraryEditCodeController.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/20.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KWCodeModel.h"

@interface KWCodeLibraryEditCodeController : NSWindowController

- (void)showWithCodeModel:(KWCodeModel *)codeModel onWindow:(NSWindow *)window finish:(void(^)(BOOL changed))finish;

- (void)reshow;

- (BOOL)isEditting;

- (void)dismiss;
@end

@interface NSWindow (KW)

@property (assign) BOOL canBeKey;

@end