//
//  RecipientController.m
//  SuperTextField
//
//  Created by ign on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RecipientController.h"
#import "RecipientViewCell.h"
#import "ShadowedTableView.h"

#define	kLeftInset 6
#define kOriginShift 9
#define kEntryFieldDefaultWidth 230
#define keyboardHeightPortrait      216
#define keyboardHeightLandscape     162
#define kFadeInAnimationDuration	0.3
#define kFadeOutAnimationDuration	0.15
#define keyboardHeightPortrait      216
#define keyboardHeightLandscape     162

#define matchListTableTag 100
#define fullListTableTag 101

#define navigationControllerTag 200

NSString *blank = @" ";

@interface RecipientController()

- (void)layoutSubviews;

@end

@implementation RecipientController

@synthesize addFromAddressBookButton;
@synthesize entryField;
@synthesize toLabel;
@synthesize namesLabel;
@dynamic selectedRecipientCell;
@synthesize defaultHeight;
@synthesize lastHeight;
@synthesize model;
@synthesize contactMatchListView;
@synthesize navController;

-(id)initWithModel:(id<DataModelDelegate>)modelL{
    self = [super init];
    if (self) {
        // Custom initialization
        self.model = modelL;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)clearEntryField{
    self.entryField.text = blank;
}

- (void)showContactMatchListView;
{
	if (self.contactMatchListView.hidden == YES)
	{
		self.contactMatchListView.alpha = 0.0;
        self.contactMatchListView.hidden = NO;
        
        CGRect listFrame = self.contactMatchListView.frame;
        listFrame.origin.y += (self.view.frame.size.height - self.defaultHeight);
        self.contactMatchListView.frame = listFrame;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kFadeInAnimationDuration];
        
        self.contactMatchListView.alpha = 1.0;
        
        listFrame.origin.y -= (self.view.frame.size.height - self.defaultHeight);
        self.contactMatchListView.frame = listFrame;
        
        if (self.view.frame.size.height > self.defaultHeight)
        {
            CGRect frame = self.view.frame;
            //frame.origin.y = -frame.size.height + self.defaultHeight;
            frame.size.height = self.defaultHeight;
            self.view.frame = frame;
        }
        
        [UIView commitAnimations];
        [self.contactMatchListView reloadData];
	}
	else
		[self.contactMatchListView reloadData];
	
}

- (void)hideContactMatchListViewAnimated:(BOOL)animated;
{
	if (self.contactMatchListView.hidden == NO)
	{
//        self.contactMatchListView.hidden = YES;
//        
//        if (self.lastHeight > self.defaultHeight)
//		{
//			CGRect frame = self.view.frame;
//			//frame.origin.y = 0;
//            frame.size.height = self.lastHeight;
//			self.view.frame = frame;
//            
//		}
        
		if (animated)
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kFadeOutAnimationDuration];
		}
		self.contactMatchListView.alpha = 0.0;
		
		if (self.lastHeight > self.defaultHeight)
		{
			CGRect frame = self.view.frame;
			//frame.origin.y = 0;
            frame.size.height = self.lastHeight;
			self.view.frame = frame;
            
		}
        
		if (animated)
		{
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(hideContactMatchListAnimationDidStop)];
			
			[UIView commitAnimations];
		}
		else
			self.contactMatchListView.hidden = YES;
        
        [self.contactMatchListView reloadData];
	}
    
}

- (void)hideContactMatchListAnimationDidStop;
{
	self.contactMatchListView.hidden = YES;
}

-(IBAction)showFullContactList:(id)sender{
    self.entryField.text = blank;
    [self hideContactMatchListViewAnimated:NO];
    [self.entryField resignFirstResponder];
    
    UITableViewController * tableController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableController.tableView.tag = fullListTableTag;
    tableController.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableController.tableView.delegate = self;
    tableController.tableView.dataSource = self;
    
    if (!self.navController) {
        self.navController = [[UINavigationController alloc] initWithRootViewController:tableController];
    }
    
    self.navController.view.tag = navigationControllerTag;
    tableController.title = @"All Contacts";
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dissmissTable)];
    tableController.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    
    //Fake modal transition because of the lack of container view controllers in IOS4
    CGRect onScreenFrame = CGRectMake(0, 0, self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
    CGRect offScreenFrame = onScreenFrame;
    offScreenFrame.origin.y = self.view.superview.bounds.size.height;
    
    self.navController.view.frame = offScreenFrame;
    [UIView beginAnimations:@"FakeModalTransition" context:nil];
    [UIView setAnimationDuration:0.4f];
    [self.view.superview addSubview:self.navController.view];
    self.navController.view.frame = onScreenFrame;
    [UIView commitAnimations];
    
    [tableController release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.entryField.text = blank;
    
    self.defaultHeight = self.view.frame.size.height;
    self.lastHeight = self.defaultHeight;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    [tap release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){ 
        
        if ([sender numberOfTouches] != 1) {
            return;
        }
        
        BOOL	cellHit = NO;
        
        for (UIView *subView in self.view.subviews)
        {
            if ([subView isKindOfClass:[RecipientViewCell class]] && !subView.hidden)
            {
                if ( CGRectContainsPoint(subView.frame, [sender locationInView:self.view]) )
                {
                    self.selectedRecipientCell.selected = NO;
                    self.selectedRecipientCell = (RecipientViewCell*)subView;
                    self.selectedRecipientCell.selected = YES;
                    cellHit = YES;
                    break;
                }
            }
        }
        
        if (cellHit == NO)
        {
            if ( CGRectContainsPoint(self.addFromAddressBookButton.frame, [sender locationInView:self.view]) )
            {
                if (self.addFromAddressBookButton.enabled) {
                    [self showFullContactList:self.addFromAddressBookButton];
                }
                
            }else{
                self.selectedRecipientCell.selected = NO;
                self.selectedRecipientCell = nil;
                self.entryField.hidden = NO;
                [self.entryField becomeFirstResponder];
            }
            
        }
    } 
}

-(void)setUpControllerView{
    CGRect frameRect = self.view.superview.bounds;
    
    self.view.frame = CGRectMake(0, 0, frameRect.size.width, self.defaultHeight);
}

-(void)setUpContactMatchView{
    CGRect frameRect = self.view.superview.bounds;
    frameRect.origin.y = self.view.frame.size.height - self.view.frame.origin.y;
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        frameRect.size.height -= (self.view.frame.size.height + keyboardHeightPortrait);
    }else{
        frameRect.size.height -= (self.view.frame.size.width + keyboardHeightLandscape);
    }
    
    //NSLog(@"h: %f w: %f x: %f y: %f",frameRect.size.height,frameRect.size.width,frameRect.origin.x,frameRect.origin.y);
    
    self.contactMatchListView = [[[ShadowedTableView alloc] initWithFrame:frameRect style:UITableViewStylePlain] autorelease];
    self.contactMatchListView.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1.0];
    self.contactMatchListView.tag = matchListTableTag;
        
    [self.view.superview addSubview:self.contactMatchListView];
    self.contactMatchListView.hidden = YES;
    self.contactMatchListView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.contactMatchListView.delegate = self;
    self.contactMatchListView.dataSource = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.addFromAddressBookButton = nil;
	self.entryField = nil;
	self.toLabel = nil;
    self.namesLabel = nil;
    
}

- (void)dealloc 
{
    
    [model release];
    
    [navController release];
    
    [selectedRecipientCell release];
    
    [super dealloc];
}

- (void)layoutSubviews
{
    //NSLog(@"laying subviews...");
	
    // we're going to loop through all the view looking for RecipientViewCell views and lay them out within this view.
	// If there are no RecipientViewCell then nothing will be changed.  The layout process knows about
	// the three views defined in the xib and will move them as necessary and well as changes the size of this view
	// as needed
	NSInteger neededRows = 1;
	CGPoint	cellLayoutPoint = self.toLabel.frame.origin;
	CGPoint fieldLayoutPoint; 
	
	NSInteger growHeight = self.entryField.frame.size.height;
    NSInteger maxHeight;
    
    CGRect frame = self.contactMatchListView.frame;
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        maxHeight = self.view.superview.frame.size.height - keyboardHeightPortrait - self.defaultHeight;
        frame.size.height = self.view.superview.frame.size.height - self.defaultHeight - keyboardHeightPortrait;
    }else{
        maxHeight = self.view.superview.frame.size.width - keyboardHeightLandscape - self.defaultHeight;
        frame.size.height = self.view.superview.frame.size.width - self.defaultHeight - keyboardHeightLandscape;
    }
    
    self.contactMatchListView.frame = frame;
	
	cellLayoutPoint.x += self.toLabel.frame.size.width + 4;
	NSInteger rightInset = self.addFromAddressBookButton.frame.origin.x - 4;
	//NSLog(@"layout.x: %f rigthInset: %d",cellLayoutPoint.x,rightInset);
	CGRect subViewRect, frameRect;
	NSInteger layoutViewCount = 0;
	for (UIView *subView in self.view.subviews)
	{
		if ([subView isKindOfClass:[RecipientViewCell class]] && !subView.hidden)
		{
			layoutViewCount ++;
			subViewRect = subView.frame;
			if (cellLayoutPoint.x + subViewRect.size.width + 4 < rightInset)
			{
				// it fits in the view so just place it at the layoutPoint
				subViewRect.origin = cellLayoutPoint;
				subViewRect.origin.y += kOriginShift;
				subView.frame = subViewRect;
				cellLayoutPoint.x += subView.frame.size.width + 4;
			}
			else
			{
				// it doesn't fit on the current line with the add contact button, let check to see
				// if it can with if we move the add button
				if (cellLayoutPoint.x + subViewRect.size.width + 8 < self.view.frame.size.width - 50)
				{
					// it fits in the view so just place it at the layoutPoint
					subViewRect.origin = cellLayoutPoint;
					subViewRect.origin.y += kOriginShift;
					subView.frame = subViewRect;
					cellLayoutPoint.x += subView.frame.size.width + 4;
				}
				else
				{
                    if (layoutViewCount == 1) 
                    {
                        subViewRect.origin = cellLayoutPoint;
                        subViewRect.origin.y += kOriginShift;
                        subViewRect.size.width = self.view.frame.size.width - cellLayoutPoint.x - 8;
                        subView.frame = subViewRect;
                        cellLayoutPoint.x += subViewRect.size.width + 4;
                    }else if (subViewRect.size.width + 4 < self.view.frame.size.width)
					{
                        // now we need to see if it will fit on a line all by itself
						// it fits
                        cellLayoutPoint.x = kLeftInset;
						cellLayoutPoint.y += growHeight;
						neededRows ++;
                        
						subViewRect.origin = cellLayoutPoint;
						subViewRect.origin.y += kOriginShift;
						subView.frame = subViewRect;	
						cellLayoutPoint.x += subView.frame.size.width + 4;
                        
					}
					else
					{
						// it doesn't fit on a line by itself, so we'll shrink
						
						// if this is the very first view being layedout then
						// we'll keep it on the first line and just shrink it.
						
                        cellLayoutPoint.x = kLeftInset;
                        cellLayoutPoint.y += growHeight;
                        neededRows ++;
                        
                        subViewRect.origin = cellLayoutPoint;
                        subViewRect.origin.y += kOriginShift;
                        subViewRect.size.width = self.view.frame.size.width - cellLayoutPoint.x - 8;
                        subView.frame = subViewRect;
                        cellLayoutPoint.x += subViewRect.size.width + 4;
                        
					}
				}
			}
            
            [subView setNeedsDisplay];
		}
	}
	
	fieldLayoutPoint = cellLayoutPoint;
	
	NSInteger remainingWidth = rightInset - fieldLayoutPoint.x;
	if ( remainingWidth > 50)
	{				
		frameRect = self.entryField.frame;
		frameRect.origin = fieldLayoutPoint;
		frameRect.size.width = remainingWidth;
		self.entryField.frame = frameRect;
	}
	else
	{
		// it doesn't fit so lets make adjustments
		fieldLayoutPoint.x = kLeftInset;
		fieldLayoutPoint.y += growHeight;
		neededRows ++;
		
		frameRect.origin = fieldLayoutPoint;
		frameRect.size.width = rightInset;
		frameRect.size.height = self.entryField.frame.size.height;
		self.entryField.frame = frameRect;
	}
    
    UIScrollView * view = (UIScrollView *)self.view;
    frameRect = view.frame;
    view.contentSize = frameRect.size;
    
	CGFloat newHeight = neededRows * growHeight;
    
    if ( newHeight > self.defaultHeight )
	{
        //NSLog(@"new: %f max: %d",newHeight,maxHeight);
        if (newHeight > maxHeight) {
            frameRect.size.height = maxHeight;
            self.view.frame = frameRect;
            
            //scroll down
            view.contentSize = CGSizeMake(frameRect.size.width, newHeight);
            
            [view scrollRectToVisible:CGRectMake(0, view.contentSize.height - self.defaultHeight, view.contentSize.width, self.defaultHeight) animated:NO];
            
//            NSLog(@"y: %f, w: %f h: %f",view.contentSize.height - self.defaultHeight,view.contentSize.width,self.defaultHeight);
        }else{
            frameRect.size.height = self.defaultHeight + ((neededRows-1) * growHeight);
            self.view.frame = frameRect;
            view.contentSize = frameRect.size;
            
        }

	}
	else
	{
		if (self.view.frame.size.height > self.defaultHeight)
		{
			frameRect = self.view.frame;
			frameRect.size.height = self.defaultHeight;
			self.view.frame = frameRect;
            view.contentSize = frameRect.size;
			
		}
	}
    
    self.lastHeight = self.view.frame.size.height;
    
    CGRect buttonFrame = self.addFromAddressBookButton.frame;
    buttonFrame.origin = CGPointMake(rightInset + 4, view.contentSize.height - self.defaultHeight + kOriginShift);
    self.addFromAddressBookButton.frame = buttonFrame;
    
    //if the contactMatchList is visible, then the height must be the default one
    if (!self.contactMatchListView.hidden)
    {
        CGRect frame = self.view.frame;
        frame.size.height = self.defaultHeight;
        self.view.frame = frame;
        
        [view scrollRectToVisible:CGRectMake(0, view.contentSize.height - self.defaultHeight, view.contentSize.width, self.defaultHeight) animated:NO];
    }
	
}

-(void)finishedAnimation{
    [[self.view.superview viewWithTag:navigationControllerTag] removeFromSuperview];
    
    [self layoutSubviews];
}

-(void)dissmissTable{
    UIView * navView = [self.view.superview viewWithTag:navigationControllerTag];
    
    CGRect onScreenFrame = CGRectMake(0, 0, self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
    CGRect offScreenFrame = onScreenFrame;
    offScreenFrame.origin.y = self.view.superview.bounds.size.height;

    [UIView beginAnimations:@"FakeModalTransition" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishedAnimation)];
    [UIView setAnimationDuration:0.4f];
    navView.frame = offScreenFrame;
    
    [UIView commitAnimations];
    
}

-(void)clearRecipients{
    for (UIView *subView in self.view.subviews){
        if ([subView isKindOfClass:[RecipientViewCell class]]){
            [subView removeFromSuperview];
        }
    }
    
    [self.model clearRecipients];
    
    [self setUpNameLabel];
}

-(void)setUpNameLabel{
    self.namesLabel.text = @"";
    
    for (UIView *subView in self.view.subviews){
        if ([subView isKindOfClass:[RecipientViewCell class]]){
            subView.hidden = YES;
            self.namesLabel.text = [NSString stringWithFormat:@"%@%@, ",self.namesLabel.text,((RecipientViewCell *)subView).cellDisplayTitle];
        }
        
    }
    
    if ([self.namesLabel.text length] > 0) {
        self.namesLabel.text = [self.namesLabel.text substringToIndex:(self.namesLabel.text.length-2)];
        self.namesLabel.hidden = NO;
    }
    
    self.selectedRecipientCell.selected = NO;
    self.selectedRecipientCell = nil;
    
    CGRect frameRect = self.view.frame;
    frameRect.origin.y = 0;
    self.view.frame = frameRect;
    
    [self layoutSubviews];
}

-(void)keyboardWillHide{
    //show one line name list
    if ([self.entryField isFirstResponder]) {
        [self setUpNameLabel];
    }
}

-(void)keyboardWillShow{
    //show contact pills
    if ([self.entryField isFirstResponder]) {
        for (UIView *subView in self.view.subviews){
            if ([subView isKindOfClass:[RecipientViewCell class]]){
                subView.hidden = NO;
            }
        }
        
        self.namesLabel.hidden = YES;
        
        [self layoutSubviews];
    }
    
}

- (RecipientViewCell*)selectedRecipientCell;
{
	return selectedRecipientCell;
}

- (void)setSelectedRecipientCell:(RecipientViewCell *)cell;
{
    UIScrollView * view = (UIScrollView *)self.view;
    [view setScrollEnabled:NO];
    
	if (selectedRecipientCell != cell)
	{       
		[self.selectedRecipientCell setNeedsDisplay];
		[selectedRecipientCell release];
		selectedRecipientCell = [cell retain];
		[self.selectedRecipientCell setNeedsDisplay];
        
        if (cell) {
            self.entryField.hidden = YES;
            self.entryField.text = @" ";	
        }
        
    }
    
    [view setScrollEnabled:YES];
}

- (void)addNewRecipient:(NSString*)recipient;
{	
    if (recipient.length == 0) {
        return;
    }
    
    if ([recipient rangeOfString:@"<"].location == NSNotFound || [recipient rangeOfString:@">"].location == NSNotFound) {
        //if it was manually entered, i copy the contents to the address
        recipient = [NSString stringWithFormat:@"%@<%@>",recipient,recipient];
    }
    
	RecipientViewCell *recipientCell = [[[RecipientViewCell alloc] initWithTitle:recipient] autorelease];
    
	[self.view addSubview:recipientCell];
	
    if (self.entryField.isFirstResponder) {
        [self layoutSubviews];
    }else{
        [self setUpNameLabel];
    }
	
	Recipient *newRecipient = [[[Recipient alloc] init] autorelease];
	
	newRecipient.recipientNameAddress = recipient;
	newRecipient.recipientViewCell = recipientCell;
	
    [model addRecipient:newRecipient];
    
}

- (void)deleteSelectedRecipient;
{
    for (Recipient *recipient in self.model.recipients )
	{
		if ([recipient.recipientViewCell isEqual:self.selectedRecipientCell])
		{
			[[recipient.recipientViewCell superview] setNeedsLayout]; 
			[recipient.recipientViewCell removeFromSuperview];
            [model removeRecipient:recipient];
			self.selectedRecipientCell = nil;
            [self layoutSubviews];
			break;
		}
	}
}

- (void)selectLastRecipientAdded;
{
    Recipient *recipient = [model lastRecipient];
    
	self.selectedRecipientCell = recipient.recipientViewCell;
	self.selectedRecipientCell.selected = YES;
}

- (void)toggleEntryFieldVisibility;
{	
	if (self.entryField.hidden || self.entryField.text.length == 1)
		self.entryField.hidden = NO;
	else
		self.entryField.hidden = YES;
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	// the user selected a return so let's add the textFields content to the 
	// list of recipients.
	[self addNewRecipient:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	
	textField.text = blank;
    
    [self hideContactMatchListViewAnimated:YES];
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField.text.length == 0)
	{
		textField.text = blank;	
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; 
{
	// NOTE: for this to work, the text field must have a blankSpace ' ' in the first position
	// the reason is, this selector will not be called on a delete key unless there is something in the
	// field.text  therefore, we put in a blankSpace
	if ([string length] == 0)		
	{
		if ([textField.text length] > 1)
		{
            //substring from index 1 to remove the whitespace at the beginning
            //NSLog(@"le paso:%@",[[textField.text substringToIndex:textField.text.length -1] substringFromIndex:1]);
            if ([model foundMatchesForSearchString:[[textField.text substringToIndex:textField.text.length -1] substringFromIndex:1]])
			{
				[self showContactMatchListView];
			}
			else
			{
				[self hideContactMatchListViewAnimated:YES];
			}
			
			return YES;
		}
		else
		{
			[self hideContactMatchListViewAnimated:YES];
            
			if (self.selectedRecipientCell)
			{
				[self deleteSelectedRecipient];
				[self toggleEntryFieldVisibility];
			}
			else
			{
				[self toggleEntryFieldVisibility];
				[self selectLastRecipientAdded];
			}
			return NO;
		}
        
	}
	else
	{
        //NSLog(@"le pasoB:%@",[[textField.text stringByAppendingString:string] substringFromIndex:1]);
        if ([model foundMatchesForSearchString:[[textField.text stringByAppendingString:string] substringFromIndex:1]])
		{
			[self showContactMatchListView];
		}
		else
		{
			[self hideContactMatchListViewAnimated:YES];
		}
	}
    
	return YES;
}

#pragma mark TableView Delegate and Data Source Methoids

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView.tag == fullListTableTag && [model respondsToSelector:@selector(contactsInitials)]) {
        return [model contactsInitials];
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
	
	return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
	if (tableView.tag == fullListTableTag && [model respondsToSelector:@selector(contactsInitials)] && [[model contactsInitials] count] > 0) {
        return (NSString *)[[model contactsInitials] objectAtIndex:section];
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    int numOfSections = 1;
    
    // Return the number of sections.
    if (tableView.tag == fullListTableTag && [model respondsToSelector:@selector(contactsInitials)]) {
        numOfSections = [[model contactsInitials] count];
    }

    return (numOfSections > 0)?numOfSections:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	
	int numOfRows = 0;
    
    if (tableView.tag == fullListTableTag) {
        if ([model respondsToSelector:@selector(contactsInitials)] && [[model contactsInitials] count] > 0) {
            numOfRows = [model contactsForInitial:(NSString *)[[model contactsInitials] objectAtIndex:section] atIndex:section];
        }else{
            numOfRows = [model totalContactsCount];
        }
        
    }else if (tableView.tag == matchListTableTag){
        numOfRows = [model countForSearchMatches];
    }
    
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *CustomCellIdentifier = @"SearchResutsViewCell";
	
	UITableViewCell *returnCell = nil;
	returnCell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
	if (returnCell == nil) 
	{
		returnCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CustomCellIdentifier] autorelease];
		returnCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	if (tableView.tag == matchListTableTag) {
        returnCell.textLabel.text = [model personNameForIndexInResults:indexPath.row];
        returnCell.detailTextLabel.text = [model personAddressForIndexInResults:indexPath.row];
    }else if(tableView.tag == fullListTableTag){
        returnCell.textLabel.text = [model personNameForIndexPath:indexPath];
        returnCell.detailTextLabel.text = [model personAddressForIndexPath:indexPath];
    }
    
	return returnCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
	NSString * recipient = [NSString stringWithFormat:@"%@<%@>",cell.textLabel.text,cell.detailTextLabel.text];
	
    [self addNewRecipient:recipient];
    
    entryField.text = blank;
    
    if (tableView.tag == matchListTableTag) {
        [self hideContactMatchListViewAnimated:YES];
    }else if(tableView.tag == fullListTableTag){
        [self dissmissTable];
    }
    
}

#pragma mark Rotation Methods

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    
//}
//
//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
//        NSLog(@"portrait");
//    }else{
//        NSLog(@"landscape");
//    }
//}


@end
