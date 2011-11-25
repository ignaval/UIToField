//
//  Recipient.h
//  MultiRecipientPicker
//
//  Created by Joe Michels on 5/18/10.
//  Copyright 2010 Software Ops LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class	RecipientViewCell;

@interface Recipient : NSObject 
{
	NSString			*recipientNameAddress;
	RecipientViewCell	*recipientViewCell;
}

// full qualifier name and address Joe Michels <joe@softwareops.com>
// Joe Michels <8005552345> for phone numbers
@property (nonatomic, retain) NSString			*recipientNameAddress;  

// just the address joe@softwareops.com
// 8005552345 for phone numbers

@property (nonatomic, readonly) NSString		*recipientAddress;  

@property (nonatomic, retain) RecipientViewCell	*recipientViewCell;

@end
