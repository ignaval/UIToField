//
//  CoreDataDataModel.m
//  UIToField
//
//  Created by ign on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataDataModel.h"

@implementation CoreDataDataModel

@dynamic recipients;

-(id)init{
    if (self = [super init]) 
	{
		
        
	}
	
	return self;
}

-(void)dealloc{
    [super dealloc];
    
}

- (BOOL)foundMatchesForSearchString:(NSString*)searchString{
    
}

- (NSInteger)countForSearchMatches{
    
}

- (NSInteger)totalContactsCount{
    
}

- (NSString*)personNameForIndexPath:(NSIndexPath *)indexP{
    
}

- (NSString*)personAddressForIndexPath:(NSIndexPath *)indexP{
    
}

- (NSString*)personNameForIndexInResults:(NSInteger)index{
    
}

- (NSString*)personAddressForIndexInResults:(NSInteger)index{
    
}

- (void)addRecipient:(Recipient*)newRecipient{
    
}

- (void)removeRecipient:(Recipient*)recipient{
    
}

- (Recipient*)lastRecipient{
    
}

@end
