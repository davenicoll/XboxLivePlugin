//
//  XboxLiveService.m
//  XboxLivePlugin
//
//  Created by Dave on 25/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLiveService.h"
#import "XboxLiveAccount.h"
#import <Adium/AIStatusControllerProtocol.h>
#import <Adium/AISharedAdium.h>
#import <AIUtilities/AIImageAdditions.h>
#import <Adium/ESDebugAILog.h>

@implementation XboxLiveService

// Account creation
- (Class)accountClass{
	return [XboxLiveAccount class];
}

// Service description
- (NSString *)serviceCodeUniqueID{
	return @"xboxlive";
}
- (NSString *)serviceID{
	return @"XboxLive";
}
- (NSString *)serviceClass{
	return @"XboxLive";
}
- (NSString *)shortDescription{
	return @"XboxLive";
}
- (NSString *)longDescription{
	return @"Xbox Live";
}
- (NSCharacterSet *)allowedCharacters{
	return [NSCharacterSet characterSetWithCharactersInString:@"+abcdefghijklmnopqrstuvwxyz0123456789@._- "];
}
- (NSCharacterSet *)ignoredCharacters{
	return [NSCharacterSet characterSetWithCharactersInString:@""];
}
- (BOOL)caseSensitive{
	return NO;
}
- (BOOL)canCreateGroupChats{
	return NO;
}
- (AIServiceImportance)serviceImportance{
	return AIServicePrimary; //AIServiceSecondary
}
- (NSImage *)defaultServiceIconOfType:(AIServiceIconType)iconType
{
	if ((iconType == AIServiceIconSmall) || (iconType == AIServiceIconList)) {
		return [NSImage imageNamed:@"xbox-small" forClass:[self class] loadLazily:YES];
	} else {
		return [NSImage imageNamed:@"xbox" forClass:[self class] loadLazily:YES];
	}
}
- (void)registerStatuses{
    AILog(@"%@", @"XboxLivePlugin registering status: STATUS_NAME_AVAILABLE");
    
	[adium.statusController registerStatus:STATUS_NAME_AVAILABLE
                           withDescription:[adium.statusController localizedDescriptionForCoreStatusName:STATUS_NAME_AVAILABLE]
                                    ofType:AIAvailableStatusType
                                forService:self];
    
    [[adium statusController] registerStatus:STATUS_NAME_INVISIBLE
							 withDescription:[[adium statusController] localizedDescriptionForCoreStatusName:STATUS_NAME_INVISIBLE]
									  ofType:AIInvisibleStatusType
								  forService:self];
}
- (BOOL)isSocialNetworkingService
{
	return NO;
}
@end
