//
//  KWCodeLibrary.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeLibrary.h"
#import "KWCodeManager.h"
#import "KWCodeItemManager.h"

static KWCodeLibrary *sharedPlugin;

@interface KWCodeLibrary ()

@property (weak) NSMenuItem *enableCodeItem;

@end

@implementation KWCodeLibrary

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
        [[KWCodeManager defaultManager] loadData];
//        [[KWCodeManager defaultManager] test];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

+ (BOOL)shouldLoadPlugin
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    return bundleIdentifier && [bundleIdentifier caseInsensitiveCompare:@"com.apple.dt.Xcode"] == NSOrderedSame;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"❤️ Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    KWCodeItemManager *manager = [[KWCodeItemManager alloc] initWithMainItemAtPath:@"Window.Code Library" beforeItemNamed:@"Devices"];
    NSMenuItem *mainMenuItem1 = [manager addItemWithTitle:@"代码库管理" action:@selector(showEditWindow) target:self];
    [mainMenuItem1 setKeyEquivalentModifierMask: NSShiftKeyMask | NSCommandKeyMask];
    [mainMenuItem1 setKeyEquivalent:@"7"];
    
    NSMenuItem *mainMenuItem2 = [manager addItemWithTitle:@"启用" action:@selector(setCodeEnable:) target:self];
    [mainMenuItem2 setKeyEquivalentModifierMask: NSShiftKeyMask | NSCommandKeyMask];
    [mainMenuItem2 setKeyEquivalent:@"8"];
    self.enableCodeItem = mainMenuItem2;
    
    [manager addItemWithTitle:@"获取帮助" action:@selector(showHelpInfo) target:self];
    [manager addItemWithTitle:[NSString stringWithFormat:@"当前版本 %@",[self getBundleVersion]] action:nil target:nil];
    return YES;
}

# pragma mark - actions | 赤羽
- (void)setCodeEnableForDisplay:(BOOL)enable
{
    self.enableCodeItem.state = enable;
}

- (void)setCodeEnable:(NSMenuItem *)item
{
    if (item.state == NSOnState) {
        item.state = NSOffState;
    } else {
        item.state = NSOnState;
    }
    [self.settingWindow setCodeEnableForDisplay:item.state];
    [KWCodeManager defaultManager].codeEnable = item.state;
}

- (void)showEditWindow
{
    [self.settingWindow showWindow:self.settingWindow];
}

- (KWCodeLibrarySettingController *)settingWindow
{
    if (!_settingWindow) {
        self.settingWindow = [[KWCodeLibrarySettingController alloc] initWithWindowNibName:@"KWCodeLibrarySettingController"];
    }
    return _settingWindow;
}

- (void)showHelpInfo
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://github.com/kevin-ma/KWCodeLibrary"]];
}

- (NSString *)getBundleVersion
{
    NSString *bundleVersion = [[self.bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return bundleVersion;
}

@end
