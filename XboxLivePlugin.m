//
//  XboxLivePlugin.m
//  XboxLivePlugin
//
//  Created by Dave on 21/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLivePlugin.h"
#import "XboxLiveService.h"
#import <Adium/ESDebugAILog.h>

//#import "PurpleSkypeAccount.h"
//#import "PurpleSkypeService.h"
//#import <AdiumLibpurple/adiumPurpleFt.h>
//#import <AdiumLibpurple/adiumPurpleEventloop.h>
//#import <Adium/ESFileTransfer.h>
//#import <libpurple/libpurple.h>

@implementation XboxLivePlugin

- (void)installPlugin
{
    [XboxLiveService registerService];
    NSLog(@"XboxLive plugin installed");
    
}

- (void)uninstallPlugin
{
    [XboxLivePlugin release];
}

- (NSString *)pluginAuthor { return @"Dave Nicoll"; }
- (NSString *)pluginVersion { return @"1.0"; } 
- (NSString *)pluginDescription { return @"An Xbox Live plugin for Adium"; }
- (NSString *)pluginURL { return @"http://davenicoll.com"; }

@end
