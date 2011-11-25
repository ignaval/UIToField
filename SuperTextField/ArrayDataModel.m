//
//  ArrayDataModel.m
//  SuperTextField
//
//  Created by ign on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArrayDataModel.h"

@implementation ArrayDataModel

@synthesize foundPeople;
@dynamic recipients;

-(id)init{
    if (self = [super init]) 
	{
		_recipients = [[NSMutableArray arrayWithCapacity:1] retain];
        contacts = [[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"john@john.com",@"dan@dan.com",@"mary@mary.com", nil] forKeys:[NSArray arrayWithObjects:@"John", @"Dan", @"Mary", nil]] retain];
        foundPeople = [[NSMutableArray array] retain];
        
	}
	
	return self;
}

-(void)dealloc{
    [super dealloc];
    
    [_recipients release];
    [contacts release];
}

- (BOOL)foundMatchesForSearchString:(NSString*)searchString{
    
    [self.foundPeople removeAllObjects];
    
    for (NSString * c in [contacts allKeys]) {
        if ([[c lowercaseString] hasPrefix:[searchString lowercaseString]]) {
            NSLog(@"added: %@",c);
            [self.foundPeople addObject:c];
        }
    }
    
    return [self.foundPeople count] > 0;
}

- (NSInteger)countForSearchMatches{
    return [self.foundPeople count];
}

- (NSString*)personNameForIndex:(NSInteger)index{
    
    return [self.foundPeople objectAtIndex:index];
    
}

- (NSString*)personAddressForIndex:(NSInteger)index{
    
    return [contacts valueForKey:[self.foundPeople objectAtIndex:index]];
    
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



@end
