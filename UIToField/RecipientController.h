//
//  RecipientController.h
//  SuperTextField
//
//  Created by ign on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipient.h"

// This view will be the container view for and edit field to add addresses, a button to add
// an address from the Contacts app, and it will also show selected recipients using a RecipientViewCell.
// This view will be controlled by the MultiRecipientPickerViewController

@protocol RecipientControlDelegate;
@class RecipientViewCell;
@protocol DataModelDelegate;

@protocol DataModelDelegate <NSObject>

@required

- (BOOL)foundMatchesForSearchString:(NSString*)searchString;
- (NSInteger)countForSearchMatches;
- (NSInteger)totalContactsCount;
- (NSString*)personNameForIndexPath:(NSIndexPath *)indexP;
- (NSString*)personAddressForIndexPath:(NSIndexPath *)indexP;
- (NSString*)personNameForIndexInResults:(NSInteger)index;
- (NSString*)personAddressForIndexInResults:(NSInteger)index;

- (void)addRecipient:(Recipient*)newRecipient;
- (void)removeRecipient:(Recipient*)recipient;

- (Recipient*)lastRecipient;

-(void)clearRecipients;

@property (nonatomic, readonly) NSArray *recipients;

@optional

//Implement if you want sections in the complete contact list
- (NSInteger)contactsForInitial:(NSString *)initial atIndex:(NSInteger) index;
- (NSArray *)contactsInitials;

@end

@interface RecipientController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
	UIButton		*addFromAddressBookButton;
	UITextField		*entryField;
	UILabel			*toLabel;
    UILabel         *namesLabel;
	RecipientViewCell	*selectedRecipientCell;
	CGFloat			defaultHeight;
    CGFloat         lastHeight;
    
    UITableView			*contactMatchListView;
    
    UINavigationController * navController;

}

-(void)setUpContactMatchView;
-(id)initWithModel:(id<DataModelDelegate>)modelL;
-(void)clearEntryField;
-(void)setUpNameLabel;
-(void)clearRecipients;

@property (nonatomic, retain) IBOutlet UIButton			*addFromAddressBookButton;
@property (nonatomic, retain) IBOutlet UITextField		*entryField;
@property (nonatomic, retain) IBOutlet UILabel			*toLabel;
@property (nonatomic, retain) IBOutlet UILabel			*namesLabel;

@property (nonatomic, retain) RecipientViewCell			*selectedRecipientCell;
@property (nonatomic, assign) CGFloat					defaultHeight;
@property (nonatomic, assign) CGFloat					lastHeight;

@property (nonatomic, retain) UITableView				*contactMatchListView;

@property (nonatomic, retain) UINavigationController	*navController;

@property (nonatomic, retain) id <DataModelDelegate> model;

@end
