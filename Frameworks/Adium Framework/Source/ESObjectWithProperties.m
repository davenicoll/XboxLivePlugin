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

#import <Adium/ESObjectWithProperties.h>
#import <AIUtilities/AIMutableOwnerArray.h>
#import <Adium/AIProxyListObject.h>

#import <objc/runtime.h>

@interface ESObjectWithProperties (AIPrivate)
- (void)_applyDelayedProperties:(NSDictionary *)infoDict;
- (id)_valueForProperty:(NSString *)key;
@end

/*!
 * @class ESObjectWithProperties
 * @brief Abstract superclass for objects with a system of properties and display arrays
 *
 * Properties are an abstracted NSMutableDictionary implementation with notification of changed
 * keys and optional delayed, grouped notification.  They allow storage of arbitrary information associate with
 * an ESObjectWithProperties subclass. Such information is not persistent across sessions.
 *
 * Properties are KVO compliant.
 *
 * Display arrays utilize AIMutableOwnerArray.  See its documentation in AIUtilities.framework.
 */
@implementation ESObjectWithProperties

- (void)clearProxyObjects
{
	for (AIProxyListObject *proxy in proxyObjects)
		[AIProxyListObject releaseProxyObject:proxy];
	[proxyObjects release]; proxyObjects = nil;	
}

/*!
 * @brief Deallocate
 */
- (void)dealloc
{
	[self clearProxyObjects];

	[propertiesDictionary release]; propertiesDictionary = nil;
	[changedProperties release]; changedProperties = nil;
	[displayDictionary release]; displayDictionary = nil;

	[super dealloc];
}

//Setting properties ---------------------------------------------------------------------------------------------------
#pragma mark Setting Properties

/*!
 * @brief Set a property
 *
 * @param value The value
 * @param key The property to set the value to.
 * @param notify The notification timing. One of NotifyNow, NotifyLater, or NotifyNever.
 */
- (void)setValue:(id)value forProperty:(NSString *)key notify:(NotifyTiming)notify
{
    NSParameterAssert(key != nil);
    id oldValue = [self _valueForProperty:key];
    if (value == oldValue) { //No need to do all this work just to stay the same
        return;
    }
        
    [self willChangeValueForKey:key];
    	
	Ivar ivar = class_getInstanceVariable([self class], [key UTF8String]);
	
	// fall back to the dictionary
	if (ivar == NULL) {
		
		if (!propertiesDictionary && value) {
			// only allocate the dictionary when we're going to actually use it
			propertiesDictionary = [[NSMutableDictionary alloc] init];
		}
		
		if (value) {
			[propertiesDictionary setObject:value forKey:key];
		} else {
			[propertiesDictionary removeObjectForKey:key];
		}
		
	} else {
		const char *ivarType = ivar_getTypeEncoding(ivar);
		
		// check if it's a primitive type, if so, attempt to unwrap value
		if (ivarType[0] == _C_ID) {
			
			[oldValue release];
			object_setIvar(self, ivar, [value retain]);
			
		} else if (strcmp(ivarType, @encode(NSInteger)) == 0) {
			
			NSInteger iValue;
			
			if (value) {
				iValue = [value integerValue];
			} else {
				iValue = 0;
			}
			
			object_setIvar(self, ivar, (void *)iValue);
			
		}
	}
    
    [self object:self didChangeValueForProperty:key notify:notify];
    [self didChangeValueForKey:key];
}

/*!
 * @brief Set a property after a delay
 *
 * @param value The value
 * @param key The property to set the value to.
 * @param delay The delay until the change is made
 */
- (void)setValue:(id)value forProperty:(NSString *)key afterDelay:(NSTimeInterval)delay
{
	[self performSelector:@selector(_applyDelayedProperties:)
			   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
				   key, KEY_KEY,
				   value, KEY_VALUE,
				   nil]
			   afterDelay:delay];
}

- (id)valueForUndefinedKey:(NSString *)inKey
{
	return [self valueForProperty:inKey];
}

/*!
 * @brief Perform a delayed property change
 *
 * Called as a result of -[ESObjectWithProperties setValue:forProperty:afterDelay:]
 */
- (void)_applyDelayedProperties:(NSDictionary *)infoDict
{
	id				object = [infoDict objectForKey:KEY_VALUE];
	NSString		*key = [infoDict objectForKey:KEY_KEY];
	
	[self setValue:object forProperty:key notify:NotifyNow];
}

/*!
 * @brief Notify of any property changes made with a NotifyTiming of NotifyLater
 *
 * @param silent YES if the notification should be marked as silent
 */
- (void)notifyOfChangedPropertiesSilently:(BOOL)silent
{
    if (changedProperties && [changedProperties count]) {
		//Clear changedProperties in case this status change invokes another, and we re-enter this code
		NSSet	*keys = changedProperties;
		changedProperties = nil;
		
		[self didModifyProperties:keys silent:silent];
		
		[self didNotifyOfChangedPropertiesSilently:silent];
		
		[keys release];
    }
}

//Getting properties ---------------------------------------------------------------------------------------------------
#pragma mark Getting Properties

@synthesize properties = propertiesDictionary;

/*!
 * @brief Compatibility class
 * @result A call to the private class here for safety's sake.
 */
- (id)valueForProperty:(NSString *)key
{
    return [self _valueForProperty:key];
}

/*!
 * @brief Value for a property
 * @result The value associated with the passed key, or nil if none has been set.
 */
- (id)_valueForProperty:(NSString *)key
{
	id ret = nil;
	id value = nil;
	
	Ivar ivar = object_getInstanceVariable(self, [key UTF8String], (void **)&value);
	
	if (ivar == NULL) {
		
		// no dictionary -> this property is certainly nil
		if (propertiesDictionary) {
			ret = [propertiesDictionary objectForKey:key];
		}
		
	} else {
		
		const char *ivarType = ivar_getTypeEncoding(ivar);
		
		// attempt to wrap it, if we know how
		if (strcmp(ivarType, @encode(NSInteger)) == 0) {
			ret = [[[NSNumber alloc] initWithInteger:(NSInteger)value] autorelease];
		} else if (ivarType[0] != _C_ID) {
			AILogWithSignature(@" *** This ivar is not an object but an %s! Should not use -valueForProperty: @\"%@\" ***", ivarType, key);
		} else {
			ret = [[value retain] autorelease];
		}
	}
	
    return ret;
}

/*!
 * @brief Integer for a property
 *
 * @result int value for key, or 0 if no value is set for key
 */
- (NSInteger)integerValueForProperty:(NSString *)key
{
	NSInteger ret = 0;
	
	Ivar ivar = class_getInstanceVariable([self class], [key UTF8String]);
	
	if (ivar == NULL) {
		NSNumber *number = [self numberValueForProperty:key];
		ret = number ? [number integerValue] : 0;
	} else {
		
		const char *ivarType = ivar_getTypeEncoding(ivar);
		
		if (strcmp(ivarType, @encode(NSInteger)) != 0) {
			AILogWithSignature(@"%@'s %@ ivar is not an NSInteger but an %s! Will attempt to cast, but should not use -integerValueForProperty: @\"%@\"", self, key, ivarType, key);
		}
		
		ret = (NSInteger)object_getIvar(self, ivar);
	}
	
    return ret;
}

- (int)intValueForProperty:(NSString *)key
{
	int ret = 0;
	
	NSNumber *number = [self numberValueForProperty:key];
	ret = number ? [number intValue] : 0;
	
    return ret;
}

- (BOOL)boolValueForProperty:(NSString *)key
{
	BOOL ret = FALSE;
	
	NSNumber *number = [self numberValueForProperty:key];
	ret = number ? [number boolValue] : NO;
	
    return ret;
}

/*!
 * @brief NSNumber value for a property
 *
 * @result The NSNumber for this key, or nil if no such key is set or the value is not an NSNumber
 */
- (NSNumber *)numberValueForProperty:(NSString *)key
{
	id obj = [self valueForProperty:key];
	return ((obj && [obj isKindOfClass:[NSNumber class]]) ? obj : nil);
}

//For Subclasses -------------------------------------------------------------------------------------------------------
#pragma mark For Subclasses

/*!
 * @brief Sublcasses should implement this method to take action when a property changes for this object or a contained one
 *
 * @param inObject An object, which may be this object or any object contained by this one
 * @param key The key
 * @param notify A NotifyTiming value determining when notification is desired
 */
- (void)object:(id)inObject didChangeValueForProperty:(NSString *)key notify:(NotifyTiming)notify 
{
	/* If the property changed for the same object receiving this method, we should send out a notification or note it for later.
	 * If we get passed another object, it's just an informative message which shouldn't be triggering notification.
	 */
	if (inObject == self) {
		switch (notify) {
			case NotifyNow: {
				//Send out the notification now
				[self didModifyProperties:[NSSet setWithObject:key]
								   silent:NO];
				break;
			}
			case NotifyLater: {
				//Add this key to changedStatusKeys for later notification 
				if (!changedProperties) changedProperties = [[NSMutableSet alloc] init];
				[changedProperties addObject:key];
				break;
			}
			case NotifyNever: break; //Take no notification action
		}
	}
}

/*!
 * @brief Subclasses should implement this method to respond to a change of a property.
 *
 * The subclass should post appropriate notifications at this time.
 *
 * @param keys The keys
 * @param silent YES indicates that this should not trigger 'noisy' notifications - it is appropriate for notifications as an account signs on and notes tons of contacts.
 */
- (void)didModifyProperties:(NSSet *)keys silent:(BOOL)silent {};


/*!
 * @brief Subclasses should implement this method to respond to a change of properties after notifications have been posted.
 *
 * @param silent YES indicates that this should not trigger 'noisy' notifications - it is appropriate for notifications as an account signs on and notes tons of contacts.
 */
- (void)didNotifyOfChangedPropertiesSilently:(BOOL)silent {};

//Dynamic Display------------------------------------------------------------------------------------------------------
#pragma mark Dynamic Display
//Access to the display arrays for this object.  Will alloc and init an array if none exists.
- (AIMutableOwnerArray *)displayArrayForKey:(NSString *)inKey
{
	if(!displayDictionary) {
		displayDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
	}
	
    AIMutableOwnerArray	*array = [displayDictionary objectForKey:inKey];
	
    if (!array) {
        array = [[AIMutableOwnerArray alloc] init];
		[array setDelegate:self];
        [displayDictionary setObject:array forKey:inKey];
		[array release];
    }
	
    return array;
}

//With create:YES, this is identical to displayArrayForKey:
//With create:NO, just perform the lookup and return either a mutableOwnerArray or nil
- (AIMutableOwnerArray *)displayArrayForKey:(NSString *)inKey create:(BOOL)create
{
	AIMutableOwnerArray	*array;
	
	if (create) {
		array = [self displayArrayForKey:inKey];
	} else {
		array = [displayDictionary objectForKey:inKey];
	}
	
	return array;
}

- (id)displayArrayObjectForKey:(NSString *)inKey
{
	return ([[displayDictionary objectForKey:inKey] objectValue]);
}

//A mutable owner array (one of our displayArrays) set an object
- (void)mutableOwnerArray:(AIMutableOwnerArray *)inArray didSetObject:(id)anObject withOwner:(id)inOwner priorityLevel:(float)priority
{
	
}

//Naming ---------------------------------------------------------------------------------------------------------------
#pragma mark Naming

//Subclasses should override this to provide a general display name
- (NSString *)displayName
{
	return @"";
}

//Subclasses should override this to provide an ID suitable for comparing using isEqual:
- (NSString *)internalObjectID
{
	return @"";
}

#pragma mark Proxy objects

/*!
 * @brief Return a set of all proxy objects currently alive for this object
 */
- (NSSet *)proxyObjects
{
	return proxyObjects;
}

/*!
 * @brief Note that a proxy object has been created for this object
 */
- (void)noteProxyObject:(id)proxyObject
{
	if (!proxyObjects) proxyObjects = [[NSMutableSet alloc] init];
	[proxyObjects addObject:proxyObject];
}

/*!
 * @brief Notify that a proxy object has been removed for this object
 */
- (void)removeProxyObject:(id)proxyObject
{
	if (proxyObject) {
		[AIProxyListObject releaseProxyObject:proxyObject];
		[proxyObjects removeObject:proxyObject];
	}
}

@end
