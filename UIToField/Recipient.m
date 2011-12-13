//
//  Recipient.m
//  MultiRecipientPicker
//
//  Created by Joe Michels on 5/18/10.
//  Copyright 2010 Software Ops LLC. All rights reserved.
//

#import "Recipient.h"


@implementation Recipient

@synthesize recipientNameAddress;
@synthesize recipientViewCell;
@dynamic recipientAddress;


- (void)dealloc;
{
	self.recipientNameAddress = nil;
	self.recipientViewCell = nil;
	
	[super dealloc];
}

- (NSString*)recipientAddress;
{
    NSString * address = [self.recipientNameAddress substringFromIndex:[self.recipientNameAddress rangeOfString:@"<"].location + 1];
    
    return [address substringToIndex:[address rangeOfString:@">"].location];
	
}

-(NSString *)recipientName{
    return [self.recipientNameAddress substringToIndex:[self.recipientNameAddress rangeOfString:@"<"].location];
}

@end

