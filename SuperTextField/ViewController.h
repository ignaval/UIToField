//
//  ViewController.h
//  SuperTextField
//
//  Created by ign on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipientControl.h"
#import "Recipient.h"

@protocol DataModelDelegate <NSObject>

@required

- (BOOL)foundMatchesForSearchString:(NSString*)searchString;
- (NSInteger)countForSearchMatches;
- (NSString*)personNameForIndex:(NSInteger)index;
- (NSString*)personAddressForIndex:(NSInteger)index;

- (void)addRecipient:(Recipient*)newRecipient;
- (void)removeRecipient:(Recipient*)recipient;

- (Recipient*)lastRecipient;

@property (nonatomic, readonly) NSArray *recipients;

@end

@interface ViewController : UIViewController<UITextFieldDelegate, RecipientControlDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    RecipientControl	*recipientControl;
	UIButton			*addFromAddressBookButton;
	UITextField			*entryField;
	UITableView			*contactMatchListView;
    
    id <DataModelDelegate> model;
    
}

@property (nonatomic, retain) IBOutlet RecipientControl	*recipientControl;
@property (nonatomic, retain) IBOutlet UIButton			*addFromAddressBookButton;
@property (nonatomic, retain) IBOutlet UITextField		*entryField;
@property (nonatomic, retain) UITableView				*contactMatchListView;

@property (nonatomic, retain) id model;

@end
