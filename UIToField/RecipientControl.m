//
//  RecipientView.m
//  MultiRecipientPicker
//
//  Created by Joe Michels on 5/14/10.
//  Copyright 2010 Software Ops LLC. All rights reserved.
//

#import "RecipientControl.h"
#import "RecipientViewCell.h"

#define	kLeftInset 6
#define kOriginShift 9
#define kEntryFieldDefaultWidth 230
#define keyboardHeightPortrait      216
#define keyboardHeightLandscape     162

@implementation RecipientControl
@synthesize addFromAddressBookButton;
@synthesize entryField;
@synthesize toLabel;
@synthesize namesLabel;
@synthesize delegate;
@dynamic selectedRecipientCell;
@synthesize defaultHeight;

//- (id)initWithFrame:(CGRect)frame {
//    if ((self = [super initWithFrame:frame])) {
//        // Initialization code
//    }
//    return self;
//}

- (void)awakeFromNib;
{
	self.defaultHeight = self.frame.size.height;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
	
}

-(void)keyboardWillHide{
    NSLog(@"called didHide");
    //show one line name list
    if ([self.entryField isFirstResponder]) {
        self.namesLabel.text = @"";
        
        for (UIView *subView in self.subviews){
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
        
        CGRect frameRect = self.frame;
        frameRect.origin.y = 0;
        self.frame = frameRect;
        
        [self layoutSubviews];
    }
}

-(void)keyboardWillShow{
    //show contact pills
    NSLog(@"called willshow");
    if ([self.entryField isFirstResponder]) {
        for (UIView *subView in self.subviews){
            if ([subView isKindOfClass:[RecipientViewCell class]]){
                subView.hidden = NO;
            }
        }
        
        self.namesLabel.hidden = YES;
        
        [self layoutSubviews];
    }
    
}

- (void)dealloc 
{
	self.addFromAddressBookButton = nil;
	self.entryField = nil;
	self.toLabel = nil;
	self.selectedRecipientCell = nil;

    [super dealloc];
}

-(void)viewDidLoad{
    NSLog(@"called viewDidLoad");
}

- (void)drawRect:(CGRect)rect 
{
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();	
	
	CGContextSaveGState(context);
	
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height );
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height );
	
	[[UIColor	colorWithWhite:0.75 alpha:1.0] set];
	CGContextSetLineWidth (context, 1.0);
	CGContextStrokePath(context);
	
	CGContextRestoreGState(context);
	
}

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
        maxHeight = self.superview.frame.size.height - keyboardHeightPortrait;
    }else{
        maxHeight = self.superview.frame.size.height - keyboardHeightLandscape;
    }
	
	cellLayoutPoint.x += self.toLabel.frame.size.width + 4;
	NSInteger rightInset = self.addFromAddressBookButton.frame.origin.x - 4;
	
	CGRect subViewRect, frameRect;
	NSInteger layoutViewCount = 0;
	for (UIView *subView in self.subviews)
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
					if (subViewRect.size.width + 4 < self.frame.size.width)
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
							subViewRect.size.width = self.frame.size.width - cellLayoutPoint.x - 4;
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
		frameRect = self.frame;
		frameRect.size.height = self.defaultHeight + ((neededRows-1) * growHeight);
		self.frame = frameRect;
		[self setNeedsDisplay];
		//[delegate recipientViewFrameDidChange];
        
        if (newHeight > maxHeight) {
            //move the view up
            int excess = newHeight - maxHeight;
            frameRect = self.frame;
            frameRect.origin.y = -excess - self.defaultHeight;
            self.frame = frameRect;
        }else{
            frameRect = self.frame;
            frameRect.origin.y = 0;
            self.frame = frameRect;
        }
	}
	else
	{
		if (self.frame.size.height > self.defaultHeight)
		{
			frameRect = self.frame;
			frameRect.size.height = self.defaultHeight;
			self.frame = frameRect;
			[self setNeedsDisplay];
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

-(void)hideEmptyLine{
    
}


#pragma mark control tracking methods
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	//	BOOL sRet = [super beginTrackingWithTouch:touch withEvent:event];
	BOOL	cellHit = NO;
	for (UIView *subView in self.subviews)
	{
		if ([subView isKindOfClass:[RecipientViewCell class]] && !subView.hidden)
		{
			if ( CGRectContainsPoint(subView.frame, [touch locationInView:self]) )
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

@end
