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
	NSScanner *titleScanner = [NSScanner scannerWithString:self.recipientNameAddress];
	NSString *returnString;
	
	if ( [titleScanner scanUpToString:@"<" intoString:&returnString] == NO )
	{
		returnString = nil;
	}
	else
		if ( [titleScanner scanUpToString:@">" intoString:&returnString] == NO )
		{
			returnString = nil;
		}
		else
		{
			NSCharacterSet *removeSet = [NSCharacterSet characterSetWithCharactersInString:@"<> "];
			returnString = [returnString stringByTrimmingCharactersInSet:removeSet];
		}
	
	return returnString ;
	
}
@end

