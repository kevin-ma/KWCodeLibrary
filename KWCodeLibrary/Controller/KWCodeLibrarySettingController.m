//
//  KWCodeLibrarySettingController.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/15.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeLibrarySettingController.h"
#import "KWCodeModel.h"
#import "KWCodeManager.h"
#import "KWCodeLibrary.h"
#import "KWCodeLibrary.h"
#import "KWCodeLibraryEditCodeController.h"
#import "KWCodeLibraryDownloader.h"
#import "NSAlert+KWCodeLibrary.h"
#import "KWCodeFilter.h"
#import "KWXcodeCodeSnippetHandler.h"

@interface KWCodeLibrarySettingController () <NSSearchFieldDelegate,NSAlertDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *enableButton;
@property (weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, strong) KWCodeLibraryEditCodeController *editWindowController;

@property (weak) IBOutlet NSMenuItem *importSnippetItem;

@property (weak) IBOutlet NSButton *continueEditButton;

@property (copy) NSString *filterString;

@property (strong) NSArray *codeList;

@property (nonatomic, strong) KWCodeFilter *codeFilter;

@end

@implementation KWCodeLibrarySettingController

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.minSize = NSMakeSize(550, 200);
    [self.window makeFirstResponder:nil];
    [self reloadDataWithFilter:nil];
    self.continueEditButton.hidden = YES;
    self.enableButton.state = [KWCodeManager defaultManager].isCodeEnable;
    [self importFromSnippetCheck];
}

- (void)reloadDataWithFilter:(NSString *)filter
{
    NSArray *array = [[KWCodeManager defaultManager].allModel copy];
    if (filter) {
        if (!self.codeFilter) {
            self.codeFilter = [[KWCodeFilter alloc] init];
            [self.codeFilter configProperties:@[@"title",@"shortcut",@"summary"]];
        }
        self.codeList = [self.codeFilter filterResultWithExpress:filter withSource:array];
    } else {
        self.codeList = array;
    }
    [self.tableView reloadData];
}

#pragma mark - NSTableView Datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger count = self.codeList.count;
    tableView.superview.superview.hidden = !count;
    return count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{

    KWCodeModel *model = self.codeList[row];
    
    NSString *undefine = @"";
    
    NSString *no = [NSString stringWithFormat:@"%ld",(long)row];
    NSString *title = model.title;
    NSString *summary = model.summary ? : undefine;
    NSString *shortcut = model.shortcut;
    NSString *snippet = model.snippet;
    
    return @[no,title,summary,shortcut,snippet][[tableView.tableColumns indexOfObject:tableColumn]];
}

#pragma mark - NSTableView Delegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    KWCodeModel *model = self.codeList[row];
    __weak typeof(self) ws = self;
    [self.editWindowController showWithCodeModel:model onWindow:self.window finish:^(BOOL changed) {
        __strong typeof(ws) ss = ws;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ss reloadDataWithFilter:ss.filterString];
        });
    }];
    self.continueEditButton.hidden = YES;
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    KWCodeModel *model = self.codeList[row];

    NSArray *lines = [model.snippet componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (lines.count == 0 || lines.count == 1) {
        return 30;
    }
    return lines.count * 18;
}

# pragma mark - actions | 赤羽
- (void)setCodeEnableForDisplay:(BOOL)enable
{
    self.enableButton.state = enable;
}

- (IBAction)resetAction:(id)sender
{
    __weak typeof(self) ws = self;
    [NSAlert alertNoticeOnWindow:self.window withTitle:@"确定要还原到默认状态？" message:@"如果继续操作，会将代码库还原到默认状态，并且无法恢复，是否确定继续操作？" positiveButton:@"还原" negativeButton:@"取消" action:^(BOOL positive) {
        __strong typeof(ws) ss = ws;
        if (positive) {
            [[KWCodeManager defaultManager] removeAll];
            [ss loadFromDefault:nil];
            [ss reloadDataWithFilter:ss.filterString];
        }
    }];
}

- (IBAction)importFromSnippetAction:(id)sender
{
    __weak typeof(self) ws = self;
    [[KWCodeManager defaultManager] importFromCodeSnippetWithComplete:^() {
        __strong typeof(ws) ss = ws;
        [ss reloadDataWithFilter:ss.filterString];
    }];
}

- (IBAction)enableAction:(NSButton *)sender
{
    if (sender.state == NSOnState) {
        [KWCodeManager defaultManager].codeEnable = YES;
    } else {
        [KWCodeManager defaultManager].codeEnable = NO;
    }
    [[KWCodeLibrary sharedPlugin] setCodeEnableForDisplay:sender.state];
}

// 清空
- (IBAction)searchAction:(id)sender
{
    [self.searchField setStringValue:@""];
    [self onEnter:self.searchField];
}

- (IBAction)addAction:(id)sender
{
    __weak typeof(self) ws = self;
    [self.editWindowController showWithCodeModel:nil onWindow:self.window finish:^(BOOL changed) {
        __strong typeof(ws) ss = ws;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ss reloadDataWithFilter:ss.filterString];
        });
    }];
    self.continueEditButton.hidden = YES;
}

- (IBAction)delAction:(id)sender
{
    NSInteger row = [self.tableView selectedRow];
    if (row == -1 || row == NSNotFound) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"确定要清空?"];
        [alert setInformativeText:@"如果继续执行将清空代码库，该操作无法恢复，你确定要继续吗?"];
        [alert addButtonWithTitle:@"清空"];
        [alert addButtonWithTitle:@"取消"];
        alert.alertStyle = NSWarningAlertStyle;
        __weak typeof(self) ws = self;
        [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
            __strong typeof(ws) ss = ws;
            if (returnCode == 1000) {
                [[[KWCodeManager defaultManager] removeAll] synchronize];
                [ss reloadDataWithFilter:ss.filterString];
            }
        }];
        return;
    }
    KWCodeModel *model = self.codeList[row];
    NSInteger index = [[KWCodeManager defaultManager] indexForModelWithShortcut:model.shortcut andTitle:model.title];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"确定要删除?"];
    [alert setInformativeText:@"如果继续操作将删除这项，将无法还原，确定要删除吗？"];
    [alert addButtonWithTitle:@"删除"];
    [alert addButtonWithTitle:@"取消"];
    __weak typeof(self) ws = self;
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        __strong typeof(ws) ss = ws;
        switch (returnCode) {
            case 1000:
                [[[KWCodeManager defaultManager] removeModelAtIndex:index] synchronize];
                [ss reloadDataWithFilter:ss.filterString];
                break;
            case 1001:
                break;
            default:
                break;
        }
    }];
}

- (IBAction)editAction:(id)sender
{
    NSInteger row = [self.tableView selectedRow];
    if (row == -1 || row == NSNotFound) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"错误"];
        [alert setInformativeText:@"你还没有选中要编辑的项目"];
        [alert addButtonWithTitle:@"知道了"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    KWCodeModel *model = self.codeList[row];
    __weak typeof(self) ws = self;
    [self.editWindowController showWithCodeModel:model onWindow:self.window finish:^(BOOL changed) {
        __strong typeof(ws) ss = ws;
        [ss reloadDataWithFilter:ss.filterString];
    }];
    self.continueEditButton.hidden = YES;
}

- (IBAction)onEnter:(id)sender
{
    self.filterString = self.searchField.stringValue;
    if (self.filterString.length == 0) {
        self.filterString = nil;
    }
    [self reloadDataWithFilter:self.filterString];
}

- (IBAction)importAction:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"请选择要导入的文件"];
    [openPanel setCanChooseDirectories:NO];
    __weak typeof(self) ws = self;
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        __strong typeof(ws) ss = ws;
        if (result == NSModalResponseOK) {
            [[KWCodeManager defaultManager] importWithFileUrl:[openPanel URL]];
            [ss reloadDataWithFilter:ss.filterString];
        }
    }];
}

- (IBAction)exportAction:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"Untitle.plist"];
    [panel setMessage:@"请选择要保存文件的路径"];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"plist"]];
    [panel setExtensionHidden:YES];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            [[KWCodeManager defaultManager] exportWithFileUrl:[panel URL]];
        }
    }];
}

- (IBAction)continueAction:(id)sender
{
    [self.editWindowController reshow];
    self.continueEditButton.hidden = YES;
}

- (KWCodeLibraryEditCodeController *)editWindowController
{
    if (!_editWindowController) {
        _editWindowController = [[KWCodeLibraryEditCodeController alloc] init];
    }
    return _editWindowController;
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [self hideEditWindowIfNeeded];
    [self importFromSnippetCheck];
}

- (void)importFromSnippetCheck
{
    BOOL has = [KWXcodeCodeSnippetHandler hasCustomCodeSnippet];
    self.importSnippetItem.enabled = has;
}

// 隐藏编辑界面
- (void)hideEditWindowIfNeeded
{
    if (_editWindowController.isEditting) {
        self.continueEditButton.hidden = NO;
        [_editWindowController dismiss];
    }
}

# pragma mark - menu | 赤羽
- (IBAction)updateFromRemote:(id)sender
{
    __weak typeof(self) ws = self;
    [[[KWCodeLibraryDownloader alloc] init] downloadCodeSnippetListWithCompletion:^(NSString *path, NSError *error) {
        __strong typeof(ws) ss = ws;
        if (path) {
            [[KWCodeManager defaultManager] importWithFileUrl:[NSURL fileURLWithPath:path]];
            [self reloadDataWithFilter:ss.filterString];
        } else {
            [NSAlert alertNoticeWithTitle:@"导入失败" message:@"请检查文件格式是否正确"];
        }
    }];
}

- (IBAction)loadFromDefault:(id)sender
{
    [KWCodeLibraryDownloader resetCodeSnippetRepoPath];
    [self updateFromRemote:sender];
}

- (IBAction)loadFromCustom:(id)sender
{
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"请填写你要加载的远程文件地址";
    [alert addButtonWithTitle:@"保存"];
    [alert addButtonWithTitle:@"取消"];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 540, 24)];
    input.stringValue = [KWCodeLibraryDownloader CodeSnippetRepoPath];
    alert.accessoryView = input;
    
    if ([alert runModal] == NSAlertFirstButtonReturn && ![input.stringValue isEqualToString:[KWCodeLibraryDownloader CodeSnippetRepoPath]]) {
        [KWCodeLibraryDownloader setCodeSnippetRepoPath:input.stringValue];
        [self loadFromDefault:sender];
    }

}
@end
