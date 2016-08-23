//
//  IDEWorkspace+KWCodeLibrary.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "IDEWorkspace+KWCodeLibrary.h"
#import "IDEFrameworkFilePath.h"
#import "DVTFilePath.h"
#import "XCBuildConfiguration.h"
#import "PBXTarget.h"
#import "PBXProject.h"
#import "XCConfigurationList.h"
#import "DVTMacroDefinitionTable.h"

@implementation IDEWorkspace (KWCodeLibrary)

- (NSString *)xcprojFile
{
    if ([self respondsToSelector:@selector(wrappedXcode3ProjectPath)]) {
        return self.wrappedXcode3ProjectPath.pathString;
    }else if ([self respondsToSelector:@selector(wrappedContainerPath)]){
        return self.wrappedContainerPath.pathString;
    }
    
    return @"";
}

- (NSString *)currentProjectFolder
{
    return [self.representingFilePath.pathString stringByDeletingLastPathComponent];
}

- (NSArray *)defaultScanHeaderDirs
{
    NSMutableArray * dirs = [[NSMutableArray alloc] init];
    return dirs;
}

-(NSArray *)SDKDirs
{
    NSMutableArray * dirs = [[NSMutableArray alloc] init];
    return dirs;
}

-(NSArray *)_allCurProjFramworkSearchPaths:(PBXProject *)proj{
    NSArray * targets = [proj targets];
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    //read project configuration
    XCConfigurationList *configs = proj.buildConfigurationList;
    for (XCBuildConfiguration * config in configs.buildConfigurations) {
        NSString *sdkspec = [self _sdkPathOfConfiguration:config];
        if (sdkspec && ![paths containsObject:sdkspec]) {
            [paths addObject:sdkspec];
        }
    }
    
    for (PBXTarget * target in targets) {
        XCConfigurationList *clist = target.buildConfigurationList;
        
        for (XCBuildConfiguration * config in clist.buildConfigurations) {
            NSString *sdkspec = [self _sdkPathOfConfiguration:config];
            if (sdkspec && ![paths containsObject:sdkspec]) {
                [paths addObject:sdkspec];
            }
        }
    }
    return paths;
}

-(NSString *)_sdkPathOfConfiguration:(XCBuildConfiguration *)config
{
    DVTMacroDefinitionTable * macroTable = [config buildSettings];
    NSString * sdkfmt = @"/Applications/Xcode.app/Contents/Developer/Platforms/%@.platform/Developer/SDKs";
    NSString * sdk;
    NSString * platform;
    NSString * sdkVersion;
    if (macroTable) {
        NSString *sdkroot = [macroTable valueForKey:@"SDKROOT"];
        if (!sdkroot.length) {
            return nil;
        }
        
        if ([sdkroot.lowercaseString hasPrefix:@"iphoneos"]) {
            platform = @"iPhoneOS";
        }else if ([sdkroot.lowercaseString hasPrefix:@"macosx"]) {
            platform = @"MacOSX";
        }else{
            //not support
            return nil;
        }
        sdkVersion = [sdkroot substringFromIndex:platform.length];
        NSString *sdkParentDir = [NSString stringWithFormat:sdkfmt, platform];
        NSString *lastSDK = [self _lastVersionSDK:sdkParentDir paltform:platform];
        
        if (sdkVersion.length == 0) {
            return lastSDK;
        }else{
            //check spec version sdk exist
            sdk = [NSString stringWithFormat:@"%@/%@%@.sdk", sdkParentDir, platform, sdkVersion];
            if ([[NSFileManager defaultManager] fileExistsAtPath:sdk]) {
                return sdk;
            }else{
                return lastSDK;
            }
        }
    }
    
    return sdk;
}

-(NSString *)_lastVersionSDK:(NSString *)sdkParentDir paltform:(NSString *)platform{
    NSFileManager *fsmanager = [NSFileManager defaultManager];
    
    if (![fsmanager fileExistsAtPath:sdkParentDir]) {
        //not install xcode.app
        return nil;
    }
    
    NSError *err;
    NSArray * sdks = [fsmanager contentsOfDirectoryAtPath:sdkParentDir error:&err];
    if (sdks.count == 0) {
        //not install sdk
        return nil;
    }
    
    NSString *lastMainVer = @"";
    NSString *lastSubVer = @"";
    NSString *lastVersionStr = @"";
    for (NSString * sdk in sdks) {
        if (![sdk hasPrefix:platform]) {
            continue;
        }
        NSString *mv;
        NSString *sv;
        
        if ([self _versionOfSDKName:sdk platform:platform mainVer:&mv subver:&sv]) {
            if (mv.integerValue > lastMainVer.integerValue) {
                lastMainVer = mv;
                lastSubVer = sv;
                lastVersionStr = sdk;
            }else if (mv.integerValue == lastMainVer.integerValue){
                if (sv.integerValue > lastSubVer.integerValue) {
                    lastMainVer = mv;
                    lastSubVer = sv;
                    lastVersionStr = sdk;
                }
            }
        }
    }
    
    return [NSString stringWithFormat:@"%@/%@", sdkParentDir, lastVersionStr];
}

//iPhoneOS8.2.sdk
//MacOSX10.10.sdk
-(BOOL)_versionOfSDKName:(NSString*)sdkname platform:(NSString *)platform mainVer:(NSString **)mainver subver:(NSString **)subver{
    if (sdkname.length == 0) {
        return NO;
    }
    
    if (![sdkname hasPrefix:platform]) {
        return NO;
    }
    
    NSArray *tokens = [[sdkname substringFromIndex:platform.length] componentsSeparatedByString:@"."];
    
    if (tokens.count == 3) {
        *mainver = tokens[0];
        *subver = tokens[1];
        return YES;
    }
    
    return NO;
}

@end
