/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "PurpleFacebookAccount.h"
#import <Adium/AIHTMLDecoder.h>
#import <Adium/AIListContact.h>
#import <Adium/AIStatus.h>

@implementation PurpleFacebookAccount

- (const char*)protocolPlugin
{
    return "prpl-bigbrownchunx-facebookim";
}

- (NSString *)webProfileStringForContact:(AIListContact *)contact
{
	return [NSString stringWithFormat:NSLocalizedString(@"View %@'s Facebook profile", nil), 
			contact.displayName];
}

- (void)configurePurpleAccount
{
	[super configurePurpleAccount];
	
	/* We could add a pref for this, but not without some enhancements to mail notifications. Currently, this being
	 * enabled means ugly nasty "You have new mail!" popups continuously, since that's how 'notifications' are passed
	 * to us.
	 */
	purple_account_set_bool(account, "facebook_get_notifications", FALSE);
	
	// We do our own history; don't let the server's history get displayed as new messages
	purple_account_set_bool(account, "facebook_show_history", FALSE);
	
	// Use friends list as groups. This also allows moving between groups through libpurple
	purple_account_set_bool(account, "facebook_use_groups", TRUE);
	
	/* Don't prompt for authorization. Don't delete friends from the Facebook friend list,
	 * as doing so is not a clear way to remove the friend entirely but that's what would
	 * happen. Adding friends isn't supported, anyways.
	 */
	purple_account_set_bool(account, "facebook_manage_friends", FALSE);
	
	// Disable the Facebook CAPTCHA since it causes heartache and pain.
	purple_account_set_bool(account, "ignore-facebook-captcha", TRUE);
}

- (BOOL)contactListEditable
{
	return NO;
}

- (NSString *)host
{
	return @"login.facebook.com";
}

- (const char *)purpleStatusIDForStatus:(AIStatus *)statusState
							  arguments:(NSMutableDictionary *)arguments
{
	if (statusState.statusType == AIOfflineStatusType) {
		return "offline";
	} else {
		return "available";
	}
}

- (void)setSocialNetworkingStatusMessage:(NSAttributedString *)inStatusMessage
{
	NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
	NSString *encodedStatusMessage = (inStatusMessage ? 
									  [self encodedAttributedString:inStatusMessage
													 forStatusState:nil] :
									  nil);
	if (encodedStatusMessage) {
		[arguments setObject:encodedStatusMessage
					  forKey:@"message"];
	}

	purple_account_set_bool(account, "facebook_set_status_through_pidgin", TRUE);
	[self setStatusState:nil
				statusID:"available" /* facebook only supports available */
				isActive:[NSNumber numberWithBool:YES]
			   arguments:arguments];
	purple_account_set_bool(account, "facebook_set_status_through_pidgin", FALSE);
}

- (NSString *)encodedAttributedString:(NSAttributedString *)inAttributedString forListObject:(AIListObject *)inListObject
{
	return [AIHTMLDecoder encodeHTML:inAttributedString
							 headers:YES
							fontTags:YES
				  includingColorTags:YES
					   closeFontTags:YES
						   styleTags:YES
		  closeStyleTagsOnFontChange:YES
					  encodeNonASCII:NO
						encodeSpaces:NO
						  imagesPath:nil
				   attachmentsAsText:YES
		   onlyIncludeOutgoingImages:NO
					  simpleTagsOnly:NO
					  bodyBackground:NO
				 allowJavascriptURLs:YES];
}

/*!
 * @brief Set an alias for a contact
 *
 * Normally, we consider the name a 'serverside alias' unless it matches the UID's characters
 * However, the UID in facebook should never be presented to the user if possible; it's for internal use
 * only.  We'll therefore consider any alias a formatted UID such that it will replace the UID when displayed
 * in Adium.
 */
- (void)updateContact:(AIListContact *)theContact toAlias:(NSString *)purpleAlias
{
	if (![purpleAlias isEqualToString:theContact.formattedUID] && 
		![purpleAlias isEqualToString:theContact.UID]) {
		[theContact setFormattedUID:purpleAlias
							 notify:NotifyLater];
		
		//Apply any changes
		[theContact notifyOfChangedPropertiesSilently:silentAndDelayed];
	}
}

@end