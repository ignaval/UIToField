//
//  RecipientController.m
//  SuperTextField
//
//  Created by ign on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RecipientController.h"
#import "RecipientViewCell.h"
#import "ArrayDataModel.h"
#import "ShadowedTableView.h"

#define	kLeftInset 6
#define kOriginShift 9
#define kEntryFieldDefaultWidth 230
#define keyboardHeightPortrait      216
#define keyboardHeightLandscape     162
#define kFadeAnimationDuration		0.30
#define keyboardHeightPortrait      216
#define keyboardHeightLandscape     162

NSString *blank = @" ";

@implementation RecipientController

@synthesize addFromAddressBookButton;
@synthesize entryField;
@synthesize toLabel;
@synthesize namesLabel;
@synthesize delegate;
@dynamic selectedRecipientCell;
@synthesize defaultHeight;
@synthesize model;
@synthesize contactMatchListView;

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.entryField.text = blank;
    
    CGRect frameRect = self.view.superview.bounds;
    frameRect.origin.y = self.view.frame.size.height - self.view.frame.origin.y;
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        frameRect.size.height -= (self.view.frame.size.height + keyboardHeightPortrait);
    }else{
        frameRect.size.height -= (self.view.frame.size.height + keyboardHeightLandscape);
    }
    
    //NSLog(@"h: %f w: %f x: %f y: %f",frameRect.size.height,frameRect.size.width,frameRect.origin.x,frameRect.origin.y);
    
    self.contactMatchListView = [[[ShadowedTableView alloc] initWithFrame:frameRect style:UITableViewStylePlain] autorelease];
    self.contactMatchListView.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1.0];
    
    CGRect frame = self.contactMatchListView.bounds;
    frame.origin.y = -frame.size.height*2;
    frame.size.height = frame.size.height *2;
    UIView* upView = [[UIView alloc] initWithFrame:frame];
    upView.backgroundColor = self.contactMatchListView.backgroundColor;
    [self.contactMatchListView addSubview:upView];
    [upView release];
    
    [self.view.superview addSubview:self.contactMatchListView];
    self.contactMatchListView.hidden = YES;
    self.contactMatchListView.delegate = self;
    self.contactMatchListView.dataSource = self;
    
    self.defaultHeight = self.view.frame.size.height;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
	self.addFromAddressBookButton = nil;
	self.entryField = nil;
	self.toLabel = nil;
	self.selectedRecipientCell = nil;
    
    [model release];
    self.model = nil;
    
    [super dealloc];
}

//- (void)drawRect:(CGRect)rect 
//{
//	[super drawRect:rect];
//	CGContextRef context = UIGraphicsGetCurrentContext();	
//	
//	CGContextSaveGState(context);
//	
//	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height );
//	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height );
//	
//	[[UIColor	colorWithWhite:0.75 alpha:1.0] set];
//	CGContextSetLineWidth (context, 1.0);
//	CGContextStrokePath(context);
//	
//	CGContextRestoreGState(context);
//	
//}

- (void)layoutSubviews
{
    NSLog(@"laying subviews...");
	// we're going to loop through all the view looking for RecipientViewCell views and lay them out within this view.
	// If there are no RecipientViewCell then nothing will be changed.  The layout process knows about
	// the three views defined in the xib and will move them as necessary and well as changes the size of this view
	// as needed
	NSInteger neededRows = 1;
	CGPoint	cellLayoutPoint = self.toLabel.frame.origin;
	CGPoint fieldLayoutPoint; 
	
	NSInteger growHeight = self.entryField.frame.size.height;
    NSInteger maxHeight;
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) {
        maxHeight = self.view.superview.frame.size.height - keyboardHeightPortrait;
    }else{
        maxHeight = self.view.superview.frame.size.height - keyboardHeightLandscape;
    }
	
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
				//if (cellLayoutPoint.x + subViewRect.size.width + 4 < self.frame.size.width - 4)
                if (rightInset - (cellLayoutPoint.x + subViewRect.size.width) > 50)
				{
					// it fits in the view so just place it at the layoutPoint
					subViewRect.origin = cellLayoutPoint;
					subViewRect.origin.y += kOriginShift;
					subView.frame = subViewRect;
					cellLayoutPoint.x += subView.frame.size.width + 4;
				}
				else
				{
					// now we need to see if it will fit on a line all by itself
					if (subViewRect.size.width + 4 < self.view.frame.size.width)
					{
                        NSLog(@"adding line B");
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
						if (layoutViewCount == 1) 
						{
							subViewRect.origin = cellLayoutPoint;
							subViewRect.origin.y += kOriginShift;
							subViewRect.size.width = rightInset - cellLayoutPoint.x - 50;
							subView.frame = subViewRect;
							NSLog(@"adding line C");
							cellLayoutPoint.x = kLeftInset;
							cellLayoutPoint.y += growHeight;
							neededRows ++;
						}
						else
						{
                            NSLog(@"adding line D");
							cellLayoutPoint.x = kLeftInset;
							cellLayoutPoint.y += growHeight;
							neededRows ++;
							
							subViewRect.origin = cellLayoutPoint;
							subViewRect.origin.y += kOriginShift;
							subViewRect.size.width = self.view.frame.size.width - cellLayoutPoint.x - 4;
							subView.frame = subViewRect;
							cellLayoutPoint.x += subViewRect.size.width + 4;
							
						}
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
		NSLog(@"adding line E");
		fieldLayoutPoint.x = kLeftInset;
		fieldLayoutPoint.y += growHeight;
		neededRows ++;
		
		frameRect.origin = fieldLayoutPoint;
		frameRect.size.width = rightInset;
		frameRect.size.height = self.entryField.frame.size.height;
		self.entryField.frame = frameRect;
	}
	
	
	CGFloat newHeight = neededRows * growHeight;
	if ( newHeight > self.defaultHeight )
	{
		frameRect = self.view.frame;
		frameRect.size.height = self.defaultHeight + ((neededRows-1) * growHeight);
		
        NSLog(@"new: %f max: %d",newHeight,maxHeight);
        if (newHeight > maxHeight) {
            //move the view up
            NSLog(@"sASasASasASasdasd");
            float excess = newHeight - maxHeight;
            frameRect.origin.y = -excess - self.defaultHeight;
            NSLog(@"lo pase a y: %f",frameRect.origin.y);
        }else{
            frameRect.origin.y = 0;
        }
        
        self.view.frame = frameRect;
	}
	else
	{
		if (self.view.frame.size.height > self.defaultHeight)
		{
			frameRect = self.view.frame;
			frameRect.size.height = self.defaultHeight;
			self.view.frame = frameRect;
			//[self setNeedsDisplay];
			//[delegate recipientViewFrameDidChange];
		}
	}
	
    //    if (self.entryField.frame.origin.x < self.toLabel.frame.size.width && !self.entryField.isFirstResponder) {
    //        //there is an empty line
    //        NSLog(@"hiding");
    //        CGRect frameRect = self.entryField.frame;
    //        frameRect.origin.x = self.toLabel.frame.origin.x + self.toLabel.frame.size.width +4;
    //        frameRect.origin.y = self.toLabel.frame.origin.y + ((neededRows-2) * growHeight);
    //        frameRect.size.width = kEntryFieldDefaultWidth;
    //        self.entryField.frame = frameRect;
    //        
    //        frameRect = self.frame;
    //        frameRect.size.height = self.defaultHeight + ((neededRows-2) * growHeight);
    //        self.frame = frameRect;
    //        [self setNeedsDisplay];
    //        [delegate recipientViewFrameDidChange];
    //    }
	
}

-(void)keyboardWillHide{
    NSLog(@"called didHide");
    //show one line name list
    if ([self.entryField isFirstResponder]) {
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
}

-(void)keyboardWillShow{
    //show contact pills
    NSLog(@"called willshow");
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

#pragma mark control tracking methods
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	//	BOOL sRet = [super beginTrackingWithTouch:touch withEvent:event];
	BOOL	cellHit = NO;
	for (UIView *subView in self.view.subviews)
	{
		if ([subView isKindOfClass:[RecipientViewCell class]] && !subView.hidden)
		{
			if ( CGRectContainsPoint(subView.frame, [touch locationInView:self.view]) )
			{
				self.selectedRecipientCell.selected = NO;
				self.selectedRecipientCell = (RecipientViewCell*)subView;
				self.selectedRecipientCell.selected = YES;
				cellHit = YES;
			}
		}
	}
	
	if (cellHit == NO)
	{
		self.selectedRecipientCell.selected = NO;
		self.selectedRecipientCell = nil;
        self.entryField.hidden = NO;
        [self.entryField becomeFirstResponder];
		//[delegate recipientViewHit];
	}
    
	return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if ([touches count] != 1) {
        return;
    }
    
	BOOL	cellHit = NO;
    UITouch * touch = [touches anyObject];
	for (UIView *subView in self.view.subviews)
	{
		if ([subView isKindOfClass:[RecipientViewCell class]] && !subView.hidden)
		{
			if ( CGRectContainsPoint(subView.frame, [touch locationInView:self.view]) )
			{
				self.selectedRecipientCell.selected = NO;
				self.selectedRecipientCell = (RecipientViewCell*)subView;
				self.selectedRecipientCell.selected = YES;
				cellHit = YES;
			}
		}
	}
	
	if (cellHit == NO)
	{
		self.selectedRecipientCell.selected = NO;
		self.selectedRecipientCell = nil;
        self.entryField.hidden = NO;
        [self.entryField becomeFirstResponder];
		//[delegate recipientViewHit];
	}
    
}

- (RecipientViewCell*)selectedRecipientCell;
{
	return selectedRecipientCell;
}

- (void)setSelectedRecipientCell:(RecipientViewCell *)cell;
{
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
	[self layoutSubviews];
	
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
		if ([recipient.recipientViewCell isEqual:self.selectedRecipientCell])
		{
			[[recipient.recipientViewCell superview] setNeedsLayout]; 
			[recipient.recipientViewCell removeFromSuperview];
			//[[MultiRecipientModel sharedMultiRecipientModel] removeRecipient:recipient];
            [model removeRecipient:recipient];
			self.selectedRecipientCell = nil;
            [self layoutSubviews];
			break;
		}
	}
}

- (void)selectLastRecipientAdded;
{
	//Recipient *recipient = [[MultiRecipientModel sharedMultiRecipientModel] lastRecipient];
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

- (void)showContactMatchListView;
{
	if (self.contactMatchListView.hidden == YES)
	{
		self.contactMatchListView.alpha = 0.0;
        self.contactMatchListView.hidden = NO;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kFadeAnimationDuration];
        
        self.contactMatchListView.alpha = 1.0;
        
        if (self.view.frame.size.height > self.defaultHeight)
        {
            CGRect frame = self.view.frame;
            frame.origin.y = -frame.size.height + self.defaultHeight;
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
		if (animated)
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:kFadeAnimationDuration];
		}
		self.contactMatchListView.alpha = 0.0;
		
		if (self.view.frame.origin.y < 0)
		{
			CGRect frame = self.view.frame;
			frame.origin.y = 0;
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
	}
    
    [self layoutSubviews];
    
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
	
	textField.text = blank;
    
    [self hideContactMatchListViewAnimated:YES];
    [textField resignFirstResponder];
	
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
    
    entryField.text = blank;
    
    [self hideContactMatchListViewAnimated:YES];
    //[entryField resignFirstResponder];
}

@end
