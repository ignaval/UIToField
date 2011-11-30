//
//  ViewController.m
//  SuperTextField
//
//  Created by ign on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
//#import "MultiRecipientModel.h"
#import "RecipientViewCell.h"
#import "ArrayDataModel.h"
#import "ShadowedTableView.h"

#define kFadeAnimationDuration		0.30
#define keyboardHeightPortrait      216
#define keyboardHeightLandscape     162

NSString *blankSpace = @" ";

@implementation ViewController

@synthesize recipientControl;
@synthesize addFromAddressBookButton;
@synthesize entryField;
@synthesize contactMatchListView;
@synthesize model;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)addRecipientFromList:(id)sender{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.model = [[ArrayDataModel alloc] init];
        [self.model retain];
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
    
    [model release];
    self.model = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.entryField.text = blankSpace;
    
    CGRect frameRect = self.view.frame;
    frameRect.origin.y = self.recipientControl.frame.size.height - self.recipientControl.frame.origin.y;
    //frameRect.size.height -= frameRect.origin.y;
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        frameRect.size.height -= (self.recipientControl.frame.size.height + keyboardHeightPortrait);
    }else{
        frameRect.size.height -= (self.recipientControl.frame.size.height + keyboardHeightLandscape);
    }
    
    self.contactMatchListView = [[[ShadowedTableView alloc] initWithFrame:frameRect style:UITableViewStylePlain] autorelease];
    self.contactMatchListView.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1.0];
    
    CGRect frame = self.contactMatchListView.bounds;
    frame.origin.y = -frame.size.height*2;
    frame.size.height = frame.size.height *2;
    UIView* upView = [[UIView alloc] initWithFrame:frame];
    upView.backgroundColor = self.contactMatchListView.backgroundColor;
    [self.contactMatchListView addSubview:upView];
    [upView release];
    
    [self.view addSubview:self.contactMatchListView];
    self.contactMatchListView.hidden = YES;
    self.contactMatchListView.delegate = self;
    self.contactMatchListView.dataSource = self;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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

	[self.recipientControl addSubview:recipientCell];
	[self.recipientControl setNeedsLayout];
	
	Recipient *newRecipient = [[[Recipient alloc] init] autorelease];
	
	newRecipient.recipientNameAddress = recipient;
	newRecipient.recipientViewCell = recipientCell;
	
	//[[MultiRecipientModel sharedMultiRecipientModel] addRecipient:newRecipient];
    [model addRecipient:newRecipient];
    
}

- (void)deleteSelectedRecipient;
{
	//for (Recipient *recipient in [MultiRecipientModel sharedMultiRecipientModel].recipients )
    for (Recipient *recipient in model.recipients )
	{
		if ([recipient.recipientViewCell isEqual:self.recipientControl.selectedRecipientCell])
		{
			[[recipient.recipientViewCell superview] setNeedsLayout]; 
			[recipient.recipientViewCell removeFromSuperview];
			//[[MultiRecipientModel sharedMultiRecipientModel] removeRecipient:recipient];
            [model removeRecipient:recipient];
			self.recipientControl.selectedRecipientCell = nil;
			break;
		}
	}
}

- (void)selectLastRecipientAdded;
{
	//Recipient *recipient = [[MultiRecipientModel sharedMultiRecipientModel] lastRecipient];
    Recipient *recipient = [model lastRecipient];
    
	self.recipientControl.selectedRecipientCell = recipient.recipientViewCell;
	self.recipientControl.selectedRecipientCell.selected = YES;
}

- (void)toggleEntryFieldVisibility;
{	
	if (self.entryField.hidden)
		self.entryField.hidden = NO;
	else
		self.entryField.hidden = YES;
}

- (void)showContactMatchListView;
{
	if (self.contactMatchListView.hidden == YES)
	{
		self.contactMatchListView.alpha = 0.0;
        self.contactMatchListView.hidden = NO;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kFadeAnimationDuration];
        
        self.contactMatchListView.alpha = 1.0;
        
        if (self.recipientControl.frame.size.height > self.recipientControl.defaultHeight)
        {
            CGRect frame = self.recipientControl.frame;
            frame.origin.y -= (frame.size.height - self.recipientControl.defaultHeight);
            self.recipientControl.frame = frame;
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
		if (animated)
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kFadeAnimationDuration];
		}
		self.contactMatchListView.alpha = 0.0;
		
		if (self.recipientControl.frame.origin.y < 0)
		{
			CGRect frame = self.recipientControl.frame;
			frame.origin.y = 0;
			self.recipientControl.frame = frame;
		}
        
		if (animated)
		{
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(hideContactMatchListAnimationDidStop)];
			
			[UIView commitAnimations];
		}
		else
			self.contactMatchListView.hidden = YES;
	}
    
}

- (void)hideContactMatchListAnimationDidStop;
{
	self.contactMatchListView.hidden = YES;
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	// the user selected a return so let's add the textFields content to the 
	// list of recipients.
	
	[self addNewRecipient:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	
	textField.text = blankSpace;
    
    [self hideContactMatchListViewAnimated:YES];
    [textField resignFirstResponder];
	
	return YES;
}

-(void)keyboardDidHide{
    if (self.entryField.frame.origin.x < self.recipientControl.toLabel.frame.size.width) {
        //there is an empty line
        //[self.recipientControl hideEmptyLine];
        [self.recipientControl layoutSubviews];
    }
}

-(void)keyboardWillShow{
   [self.recipientControl layoutSubviews];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField.text.length == 0)
	{
		textField.text = blankSpace;	
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
            NSLog(@"le paso:%@",[[textField.text substringToIndex:textField.text.length -1] substringFromIndex:1]);
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
            
			if (self.recipientControl.selectedRecipientCell)
			{
				[self deleteSelectedRecipient];
				//[self toggleEntryFieldVisibility];
			}
			else
			{
				//[self toggleEntryFieldVisibility];
				[self selectLastRecipientAdded];
			}
			return NO;
		}
        
	}
	else
	{
        NSLog(@"le paso:%@",[[textField.text stringByAppendingString:string] substringFromIndex:1]);
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

#pragma mark protocol RecipientViewDelegate 

- (void)recipientViewFrameDidChange;
{
	
	CGRect frameRect = self.contactMatchListView.frame;
	frameRect.origin.y = self.recipientControl.frame.size.height - self.recipientControl.frame.origin.y;	
	self.contactMatchListView.frame = frameRect;
	
//	CGRect contectRect = self.contentView.frame;
//	contectRect.size.height = self.recipientControl.frame.size.height + self.detailView.frame.size.height;
//	self.contentView.frame = contectRect;
//	self.scrollView.contentSize = self.contentView.frame.size;
	
	if (self.recipientControl.frame.size.height > self.recipientControl.defaultHeight && self.contactMatchListView.hidden == NO)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kFadeAnimationDuration];
		CGRect frame = self.recipientControl.frame;
		frame.origin.y -= (frame.size.height - self.recipientControl.defaultHeight);
		self.recipientControl.frame = frame;
		
//		CGRect detailRect = self.detailView.frame;
//		detailRect.origin.y = self.recipientControl.frame.size.height - self.recipientControl.frame.origin.y;
//		self.detailView.frame = detailRect;
		
		[UIView commitAnimations];
	}
	else
	{
//		[UIView beginAnimations:nil context:NULL];
//		[UIView setAnimationDuration:kFadeAnimationDuration];
//		CGRect detailRect = self.detailView.frame;
//		detailRect.origin.y = self.recipientControl.frame.size.height - self.recipientControl.frame.origin.y;
//		self.detailView.frame = detailRect;
//		
//		[UIView commitAnimations];
	}
    
    
}

- (void)recipientViewCellWasSelected:(RecipientViewCell*)recipientCell;
{
//	self.entryField.hidden = YES;
//	self.entryField.text = blankSpace;
}

- (void)recipientViewHit;
{
//	self.recipientControl.selectedRecipientCell = nil;
//	self.entryField.hidden = NO;
//	[self.entryField becomeFirstResponder];
}

#pragma mark TableView Delegate and Data Source Methoids

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	
	//return [[MultiRecipientModel sharedMultiRecipientModel] countForSearchMatches];
    return [model countForSearchMatches];
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
	
	//returnCell.textLabel.text = [[MultiRecipientModel sharedMultiRecipientModel] personNameForIndex:indexPath.row];
    returnCell.textLabel.text = [model personNameForIndex:indexPath.row];
    returnCell.detailTextLabel.text = [model personAddressForIndex:indexPath.row];
    
	
	return returnCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
	NSString * recipient = [NSString stringWithFormat:@"%@<%@>",cell.textLabel.text,cell.detailTextLabel.text];
	
    [self addNewRecipient:recipient];
    
    entryField.text = blankSpace;
    
    [self hideContactMatchListViewAnimated:YES];
    //[entryField resignFirstResponder];
}

@end
