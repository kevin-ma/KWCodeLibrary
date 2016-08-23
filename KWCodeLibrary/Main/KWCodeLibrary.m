//
//  KWCodeLibrary.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeLibrary.h"
#import "KWCodeManager.h"

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
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
//    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
//    if (menuItem) {
//        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
//        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
//        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
//        [actionMenuItem setTarget:self];
//        [[menuItem submenu] addItem:actionMenuItem];
//        return YES;
//    } else {
//        return NO;
//    }
    NSMenu *mainMenu = [NSApp mainMenu];
    NSMenuItem *pluginsMenuItem = [mainMenu itemWithTitle:@"Code Library"];
    if (!pluginsMenuItem) {
        pluginsMenuItem = [[NSMenuItem alloc] init];
        pluginsMenuItem.title = @"Code Library";
        pluginsMenuItem.submenu = [[NSMenu alloc] initWithTitle:pluginsMenuItem.title];
        NSInteger windowIndex = [mainMenu indexOfItemWithTitle:@"Help"];
        [mainMenu insertItem:pluginsMenuItem atIndex:windowIndex];
    }
    NSMenuItem *mainMenuItem1 = [[NSMenuItem alloc] initWithTitle:@"Code Manager"
                                                          action:@selector(showEditWindow)
                                                   keyEquivalent:@""];
    [mainMenuItem1 setKeyEquivalentModifierMask: NSShiftKeyMask | NSCommandKeyMask];
    [mainMenuItem1 setKeyEquivalent:@"X"];
    
    [mainMenuItem1 setTarget:self];
    [pluginsMenuItem.submenu addItem:mainMenuItem1];
    
    NSMenuItem *mainMenuItem2 = [[NSMenuItem alloc] initWithTitle:@"Enable"
                                                           action:@selector(setCodeEnable:)
                                                    keyEquivalent:@""];
    [mainMenuItem2 setTarget:self];
    [mainMenuItem2 setState:NSOnState];
    [pluginsMenuItem.submenu addItem:mainMenuItem2];
    self.enableCodeItem = mainMenuItem2;
    
    NSMenuItem *mainMenuItem3 = [[NSMenuItem alloc] initWithTitle:@"Help"
                                                           action:@selector(showHelpInfo)
                                                    keyEquivalent:@""];
    [mainMenuItem3 setTarget:self];
    [pluginsMenuItem.submenu addItem:mainMenuItem3];
    
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
        [self alertNotice:@"Success" info:@"turned off"];
    } else {
        item.state = NSOnState;
        [self alertNotice:@"Success" info:@"turned on"];
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
