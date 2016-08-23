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

@interface KWCodeLibrarySettingController () <NSSearchFieldDelegate,NSAlertDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *enableButton;
@property (weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, strong) KWCodeLibraryEditCodeController *editWindowController;

@property (weak) IBOutlet NSButton *continueEditButton;

@property (copy) NSString *filterString;

@property (strong) NSArray *codeList;

@end

@implementation KWCodeLibrarySettingController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.minSize = NSMakeSize(550, 200);
    [self.window makeFirstResponder:nil];
    [self reloadDataWithFilter:nil];
    self.continueEditButton.hidden = YES;
    self.enableButton.state = [KWCodeManager defaultManager].isCodeEnable;
}

- (void)reloadDataWithFilter:(NSString *)filter
{
    NSArray *array = [[KWCodeManager defaultManager].allModel copy];
    if (filter) {
        NSString *like = [NSString stringWithFormat:@"%@%@%@",@"*",filter,@"*"];
        NSPredicate *likePred = [NSPredicate predicateWithFormat:@"SELF.shortcut LIKE %@",like];
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.shortcut MATCHES %@",filter];
        NSCompoundPredicate *comDict = [NSCompoundPredicate orPredicateWithSubpredicates:@[likePred, pred]];
        self.codeList = [array filteredArrayUsingPredicate:comDict];
        
    } else {
        self.codeList = array;
    }
    [self.tableView reloadData];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    if (obj.object == self.tableView) {
        NSTextView *editView = obj.userInfo[@"NSFieldEditor"];
        NSLog(@"哈哈 %@",editView.textStorage.string);
        NSInteger row = self.tableView.editedRow;
        KWCodeModel *model = self.codeList[row];
        NSInteger index = [[KWCodeManager defaultManager] indexForModelWithShortcut:model.shortcut];
        NSInteger col = self.tableView.editedColumn;
        KWCodeManager *manager = [KWCodeManager defaultManager];
        if (col == 1) {
            [manager updateModelAtIndex:index withTitle:editView.textStorage.string shortcut:nil summary:nil snippet:nil];
        } else if (col == 2) {
            [manager updateModelAtIndex:index withTitle:nil shortcut:nil summary:editView.textStorage.string snippet:nil];
        } else if (col == 3) {
            [manager updateModelAtIndex:index withTitle:nil shortcut:editView.textStorage.string summary:nil snippet:nil];
        } else if (col == 3) {
            [manager updateModelAtIndex:index withTitle:nil shortcut:nil summary:nil snippet:editView.textStorage.string];
        }
        [manager synchronize];
        [self reloadDataWithFilter:self.filterString];
    }
}

#pragma mark - NSTableView Datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger count = _codeList.count;
    tableView.superview.superview.hidden = !count;
    return count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    KWCodeModel *model = _codeList[row];
    
    NSString *title = model.title;
    NSString *summary = model.summary;
    NSString *shortcut = model.shortcut;
    NSString *snippet = model.snippet;
    
    if(tableColumn == tableView.tableColumns[0]) {
        return [NSString stringWithFormat:@"%ld",(long)row];
    }
    if (tableColumn == tableView.tableColumns[1]) {
        return title;
    }
    if (tableColumn == tableView.tableColumns[2]) {
        return summary;
    }
    if (tableColumn == tableView.tableColumns[3]) {
        return shortcut;
    }
    if (tableColumn == tableView.tableColumns[4]) {
        return snippet;
    }
    
    return @"Undefine";
}

#pragma mark - NSTableView Delegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView.tableColumns[0] == tableColumn) {
        return NO;
    }
    return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    KWCodeModel *model = _codeList[row];

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

}

- (IBAction)importFromSnippetAction:(id)sender
{
    __weak typeof(self) ws = self;
    [[KWCodeManager defaultManager] importFromCodeSnippetWithComplete:^(NSString *path, NSArray *files) {
        __strong typeof(ws) ss = ws;
        [ss reloadDataWithFilter:ss.filterString];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Delete?"];
        [alert setInformativeText:@"Do you want to clean your xode code snippet?"];
        [alert addButtonWithTitle:@"Delete"];
        [alert addButtonWithTitle:@"Cancel"];
        __weak typeof(ss) wws = ss;
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            __strong typeof(wws) sss = wws;
            switch (returnCode) {
                case 1000:
                {
                    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *filePath = [path stringByAppendingPathComponent:obj];
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                    }];
                    [sss alertNotice:@"Success" info:@"Delete code snippet finished"];
                    break;
                }
                case 1001:
                    break;
                default:
                    break;
            }
        }];
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
        [ss reloadDataWithFilter:ss.filterString];
    }];
    self.continueEditButton.hidden = YES;
}


- (IBAction)delAction:(id)sender
{
    NSInteger row = [self.tableView selectedRow];
    if (row == -1 || row == NSNotFound) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Sure ?"];
        [alert setInformativeText:@"Are you sure to clean all code snippet ?"];
        [alert addButtonWithTitle:@"Clean"];
        [alert addButtonWithTitle:@"Cancel"];
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
    KWCodeModel *model = _codeList[row];
    NSInteger index = [[KWCodeManager defaultManager] indexForModelWithShortcut:model.shortcut];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Are you sure to delete ?"];
    [alert setInformativeText:@"If you want to delete this code item, please press \"Delete\" , or press \"Cancel\" to cancel"];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
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
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"You haven't select any code item"];
        [alert addButtonWithTitle:@"OK"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    KWCodeModel *model = _codeList[row];
    __weak typeof(self) ws = self;
    [self.editWindowController showWithCodeModel:model onWindow:self.window finish:^(BOOL changed) {
        __strong typeof(ws) ss = ws;
        [ss reloadDataWithFilter:ss.filterString];
    }];
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
    [openPanel setTitle:@"Choose a config file"];
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
    [panel setMessage:@"Choose the path to save the config file."];
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
}

// 隐藏编辑界面
- (void)hideEditWindowIfNeeded
{
    if (_editWindowController.isEditting) {
        self.continueEditButton.hidden = NO;
        [_editWindowController dismiss];
    }
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
