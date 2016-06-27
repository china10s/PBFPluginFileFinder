//
//  PBFPluginFileFinder.m
//  PBFPluginFileFinder
//
//  Created by zhulin on 16/6/27.
//  Copyright © 2016年 China10s. All rights reserved.
//

#import "PBFPluginFileFinder.h"

static PBFPluginFileFinder *sharedPlugin;

@interface PBFPluginFileFinder(){
    NSString *strUrl;
}
@end

@implementation PBFPluginFileFinder

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:nil object:nil];
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
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@"F"];
        [actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask ];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    [[NSWorkspace sharedWorkspace] selectFile:strUrl inFileViewerRootedAtPath:nil];
}

- (void)notificationLog:(NSNotification *)notify
{
    if([notify.name containsString:@"IDENavigableItemCoordinatorObjectGraphChangeNotification"] ){
        id items = [notify.userInfo objectForKey:@"IDEChangedItems"];
        id item = [items firstObject];
        if([item respondsToSelector:@selector(fileURL)]){
            NSURL * url = [item performSelector:@selector(fileURL)];
            strUrl = [url.absoluteString substringFromIndex:7];
        }
    }
}


@end
