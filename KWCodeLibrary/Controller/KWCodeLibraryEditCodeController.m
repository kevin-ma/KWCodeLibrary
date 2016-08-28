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
#import "NSAlert+KWCodeLibrary.h"

@interface KWCodeLibraryEditCodeController ()
@property (weak) IBOutlet NSTextField *titleField;
@property (weak) IBOutlet NSTextField *summaryField;
@property (weak) IBOutlet NSTextField *shortcutField;
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
        self.window.title = [NSString stringWithFormat:@"正在编辑 %@",[codeModel showTipText]];
        self.shortcutField.stringValue = codeModel.shortcut;
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:codeModel.snippet];
        [self.codeField.textStorage setAttributedString:attr];
        self.summaryField.stringValue = codeModel.summary;
        self.titleField.stringValue = codeModel.title;
        self.codeModel = codeModel;
        self.overrideButton.hidden = YES;
    } else {
        self.window.title = @"添加新条目";
        self.titleField.stringValue = @"";
        self.summaryField.stringValue = @"";
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:@""];
        [self.codeField.textStorage setAttributedString:attr];
        self.shortcutField.stringValue = @"";
        self.codeModel = nil;
        self.overrideButton.hidden = NO;
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
    if (_titleField.stringValue.length == 0) {
        [NSAlert alertNoticeWithTitle:@"提交出错" message:@"请先填写标题再提交"];
        return;
    }
    if (_shortcutField.stringValue.length == 0) {
        [NSAlert alertNoticeWithTitle:@"提交出错" message:@"请先填写快捷键再提交"];
        return;
    }
    if (_codeField.textStorage.string.length == 0) {
        [NSAlert alertNoticeWithTitle:@"提交出错" message:@"请先填写代码段再提交"];
        return;
    }
    if (self.codeModel) {
        [[[KWCodeManager defaultManager] updateModelAtIndex:[[KWCodeManager defaultManager] indexForModelWithShortcut:self.codeModel.shortcut andTitle:self.codeModel.title] withTitle:_titleField.stringValue shortcut:_shortcutField.stringValue summary:_summaryField.stringValue snippet:_codeField.textStorage.string] synchronize];
    } else {
        // exist check
        if ([[KWCodeManager defaultManager] indexForModelWithShortcut:_shortcutField.stringValue andTitle:_titleField.stringValue] != KWNotFound) {
            if (!self.overrideMode) {
                [NSAlert alertNoticeWithTitle:@"提交出错" message:@"该项已经存在，如果需要替换，请勾选“覆盖已存在”选项"];

                return;
            } else {
                [[[KWCodeManager defaultManager] updateModelAtIndex:[[KWCodeManager defaultManager] indexForModelWithShortcut:_shortcutField.stringValue andTitle:_titleField.stringValue] withTitle:_titleField.stringValue ?: @"" shortcut:_shortcutField.stringValue summary:_summaryField.stringValue ?: @"" snippet:_codeField.textStorage.string] synchronize];
            }
        } else {
            [[[KWCodeManager defaultManager] addModelWithTitle:_titleField.stringValue ?: @"" shortcut:_shortcutField.stringValue summary:_summaryField.stringValue ?: @"" snippet:_codeField.textStorage.string] synchronize];
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
