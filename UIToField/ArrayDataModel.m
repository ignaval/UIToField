//
//  ArrayDataModel.m
//  SuperTextField
//
//  Created by ign on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArrayDataModel.h"

@implementation ArrayDataModel

@dynamic recipients;

-(id)init{
    if (self = [super init]) 
	{
		_recipients = [[NSMutableArray arrayWithCapacity:1] retain];
        contacts = [[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"john@john.com",@"dan@dan.com",@"mary@mary.com", @"joseph@joseph.com", nil] forKeys:[NSArray arrayWithObjects:@"John", @"Dan", @"Mary", @"Joseph", nil]] retain];
        foundPeople = [[NSMutableArray array] retain];
        
	}
	
	return self;
}

-(void)dealloc{
    [super dealloc];
    
    [_recipients release];
    [contacts release];
    [foundPeople release];
}

-(NSInteger)totalContactsCount{
    return [[contacts allKeys] count];
}

- (BOOL)foundMatchesForSearchString:(NSString*)searchString{
    
    [foundPeople removeAllObjects];
    
    for (NSString * c in [contacts allKeys]) {
        if ([[c lowercaseString] hasPrefix:[searchString lowercaseString]]) {
            [foundPeople addObject:c];
        }
    }
    
    return [foundPeople count] > 0;
}

- (NSInteger)countForSearchMatches{
    return [foundPeople count];
}

- (NSString*)personNameForIndexInResults:(NSInteger)index{
    
    return [[foundPeople sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:index];
    
}

- (NSString*)personAddressForIndexInResults:(NSInteger)index{
    
    return [contacts valueForKey:[self personNameForIndexInResults:index]];
    
}

- (NSString*)personNameForIndexPath:(NSIndexPath *)indexP{
    
    NSArray * sortedContacts = [[contacts allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    int nextLetter = 0;
    NSString * name = @"";
    
    for (int i = 0; i < [sortedContacts count]; i++) {
        if (nextLetter == indexP.section) {
            name = [sortedContacts objectAtIndex:(indexP.row + i)];
            break;
        }
        
        if (![[[sortedContacts objectAtIndex:i] uppercaseString] hasPrefix:[[[sortedContacts objectAtIndex:i+1] uppercaseString] substringToIndex:1]]) {
            nextLetter++;
        }
    }
    
    return name;
    
}

- (NSString*)personAddressForIndexPath:(NSIndexPath *)indexP{
    
    return [contacts valueForKey:[self personNameForIndexPath:indexP]];
    
}

#pragma mark Recipient List Methods

- (void)addRecipient:(Recipient*)newRecipient;
{
	[_recipients addObject:newRecipient];
}

- (void)removeRecipient:(Recipient*)recipient;
{
	[_recipients removeObject:recipient];
}

- (Recipient*)lastRecipient;
{
	return [_recipients lastObject];
}

- (NSArray*)recipients;
{
	return [[_recipients copy] autorelease];
}

-(NSArray *)contactsInitials{
    NSMutableArray * initials = [NSMutableArray array];
    
    for (NSString * c in [contacts allKeys]) {
        [initials addObject:[[c uppercaseString] substringToIndex:1]];
    }
    
    NSMutableSet * set = [NSMutableSet setWithArray:initials];
    
    return [[set allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

-(NSInteger)contactsForInitial:(NSString *)initial atIndex:(NSInteger) index{
    int contactsN = 0;
    
    for (NSString * c in [contacts allKeys]) {
        if ([[c uppercaseString] hasPrefix:[initial uppercaseString]]) {
            contactsN++;
        }
    }
    
    return contactsN;
}

@end
