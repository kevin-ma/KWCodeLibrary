//
//  KWCodeLibraryEditCodeController.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/20.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeLibraryEditCodeController.h"
#import <objc/runtime.h>
#import "KWCodeManager.h"

@interface KWCodeLibraryEditCodeController ()
@property (weak) IBOutlet NSTextField *keyField;
@property (weak) IBOutlet NSTextField *tipField;
@property (unsafe_unretained) IBOutlet NSTextView *codeField;
@property (weak) IBOutlet NSButton *overrideButton;
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *finishButton;

@property (nonatomic, assign) BOOL overrideMode;

@property (nonatomic, strong) KWCodeModel *codeModel;

@property (nonatomic, copy) void(^finishAction)(BOOL changed);

@end

@implementation KWCodeLibraryEditCodeController

- (instancetype)init
{
    if (self = [super initWithWindowNibName:@"KWCodeLibraryEditCodeController"]) {
        _overrideMode = YES;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.canBeKey = YES;
}

- (void)showWithCodeModel:(KWCodeModel *)codeModel onWindow:(NSWindow *)window finish:(void (^)(BOOL))finish
{
    if (self.window.parentWindow == nil) {
        [window addChildWindow:self.window ordered:NSWindowAbove];
    }
    self.window.alphaValue = 1.f;
    self.overrideButton.state = _overrideMode;
    if (codeModel) {
        self.window.title = [NSString stringWithFormat:@"Editing %@",[codeModel showTipText]];
        self.keyField.stringValue = codeModel.shortcut;
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:codeModel.snippet];
        [self.codeField.textStorage setAttributedString:attr];
        self.tipField.stringValue = codeModel.summary;
        self.codeModel = codeModel;
    } else {
        self.window.title = @"Adding New Item";
        self.keyField.stringValue = @"";
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:@""];
        [self.codeField.textStorage setAttributedString:attr];
        self.tipField.stringValue = @"";
        self.codeModel = nil;
    }
    [self.window makeFirstResponder:self];
    [self.window makeKeyWindow];
    _finishAction = finish;
}

- (void)dismissWithChanged:(BOOL)changed
{
    self.window.alphaValue = 0.f;
    self.finishAction(changed);
}

- (BOOL)isEditting
{
    return self.window.alphaValue;
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissWithChanged:NO];
}

- (IBAction)finishAction:(id)sender
{
    if (!_keyField.stringValue.length) {
        [self alertNotice:@"Error" info:@"the key can't be empty"];
        return;
    }
    if (!_codeField.textStorage.string) {
        [self alertNotice:@"Error" info:@"the code can't be empty"];
        return;
    }
    if (self.codeModel) {
        [[[KWCodeManager defaultManager] updateModelAtIndex:[[KWCodeManager defaultManager] indexForModelWithShortcut:self.codeModel.shortcut] withTitle:_tipField.stringValue shortcut:_keyField.stringValue summary:_tipField.stringValue snippet:_codeField.textStorage.string] synchronize];
    } else {
        // exist check
        if ([[KWCodeManager defaultManager] indexForModelWithShortcut:_keyField.stringValue] != -1) {
            if (!self.overrideMode) {
                [self alertNotice:@"Error" info:@"you did have this key in library, if you want to override, please check the override setting"];
                return;
            } else {
                [[[KWCodeManager defaultManager] updateModelAtIndex:[[KWCodeManager defaultManager] indexForModelWithShortcut:_keyField.stringValue] withTitle:_tipField.stringValue ?: @"" shortcut:_keyField.stringValue summary:_tipField.stringValue ?: @"" snippet:_codeField.textStorage.string] synchronize];
            }
        } else {
            [[[KWCodeManager defaultManager] addModelWithTitle:_tipField.stringValue ?: @"" shortcut:_keyField.stringValue summary:_tipField.stringValue ?: @"" snippet:_codeField.textStorage.string] synchronize];
        }
    }
    
    [self dismissWithChanged:YES];
}

- (IBAction)overrideModelAction:(NSButton *)sender
{
    self.overrideMode = sender.state;
}

- (void)dismiss
{
    [self dismissWithChanged:NO];
}

- (void)reshow
{
    self.window.alphaValue = 1.f;
    [self.window makeFirstResponder:self];
    [self.window makeKeyWindow];
}

- (void)alertNotice:(NSString *)string info:(NSString *)info
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:string];
    if (info != nil) {
        [alert setInformativeText:info];
    }
    [alert runModal];
}
@end

@interface NSWindow ()



@end

@implementation NSWindow (KW)

+ (void)load
{
    Method m1 = class_getInstanceMethod(self, @selector(canBecomeKeyWindow));
    Method m2 = class_getInstanceMethod(self, @selector(kw_canBecomeKeyWindow));
    method_exchangeImplementations(m1, m2);
}

- (BOOL)kw_canBecomeKeyWindow
{
    if (self.canBeKey) {
        NSLog(@"YES %@",self);
        return YES;
    } else {
        return [self kw_canBecomeKeyWindow];
    }
}

static char *kCanBeKeyKey = "kCanBeKeyKey";
- (void)setCanBeKey:(BOOL)canBeKey
{
    objc_setAssociatedObject(self, kCanBeKeyKey, @(canBeKey), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)canBeKey
{
    return [objc_getAssociatedObject(self, kCanBeKeyKey) boolValue];
}
@end
