//
//  AccountViewController.m
//  XboxLivePlugin
//
//  Created by Dave on 21/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"


@implementation AccountViewController

- (void)configureForAccount:(AIAccount *)inAccount
{
    [super configureForAccount:inAccount];
    //[checkBox_autoStartSkype setState:[[account preferenceForKey:KEY_SKYPE_AUTOSTART group:GROUP_ACCOUNT_STATUS] boolValue]];
}

- (void)saveConfiguration
{
    [super saveConfiguration];
	
	//[account setPreference:[NSNumber numberWithBool:[checkBox_skypeOutOnline state]]
	//				forKey:KEY_SKYPE_SHOW_SKYPEOUT group:GROUP_ACCOUNT_STATUS];
}

@end
