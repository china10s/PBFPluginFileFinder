//
//  PBFPluginFileFinder.h
//  PBFPluginFileFinder
//
//  Created by zhulin on 16/6/27.
//  Copyright © 2016年 China10s. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface PBFPluginFileFinder : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end