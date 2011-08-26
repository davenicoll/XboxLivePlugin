//
//  XboxLiveAccount.m
//  XboxLivePlugin
//
//  Created by Dave on 27/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLiveAccount.h"
#import <Adium/AIStatusControllerProtocol.h>
#import <AIUtilities/AIMenuAdditions.h>
#import <Adium/AISharedAdium.h> 

//#import <Adium/AIAccountControllerProtocol.h>
//#import <AIUtilities/AITigerCompatibility.h> 
//#import <Adium/ESFileTransfer.h>

@implementation XboxLiveAccount

- (BOOL)disconnectOnFastUserSwitch
{
	return YES;
}

- (const char *)protocolPlugin
{
	return "prpl-xboxlive";
}

- (const char *)purpleStatusIDForStatus:(AIStatus *)statusState
                              arguments:(NSMutableDictionary *)arguments
{
	if ([[statusState statusName] isEqualToString:STATUS_NAME_AVAILABLE])
		return "ONLINE";
	else if ([[statusState statusName] isEqualToString:STATUS_NAME_AWAY])
		return "AWAY";
	else if ([[statusState statusName] isEqualToString:STATUS_NAME_EXTENDED_AWAY])
		return "NA";
	else if ([[statusState statusName] isEqualToString:STATUS_NAME_DND])
		return "DND";
	else if ([[statusState statusName] isEqualToString:STATUS_NAME_INVISIBLE])
		return "INVISIBLE";
	else
		return "OFFLINE";
}

// and add new menuitem
- (NSArray *)accountActionMenuItems
{
    /*
	NSMutableArray *menuItemArray = [[super accountActionMenuItems] mutableCopy];
	NSMenuItem			*menuItem;
	
	[menuItemArray addObject:[NSMenuItem separatorItem]];
	menuItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Change Alias Format"
																	 target:self
																	 action:@selector(toggleNameAction:)
															  keyEquivalent:@""] autorelease];
	if (!menuItemArray) menuItemArray = [NSMutableArray array];
	
	[menuItemArray addObject:menuItem];
	
	return [menuItemArray autorelease];
     */
}

- (void)toggleNameAction:(NSMenuItem *)sender
{
    /*
	int choice = purple_account_get_int(account, "view_buddies_by", NATEON_VIEW_BUDDIES_BY_SCREEN_NAME);
    
	if (choice == NATEON_VIEW_BUDDIES_BY_NAME_AND_SCREEN_NAME) {
		choice = NATEON_VIEW_BUDDIES_BY_NAME;
	} else {
		choice++;
	}
	[self viewBuddiesBy:choice];
     */
}

@end
