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

@implementation RecipientControl
@synthesize addFromAddressBookButton;
@synthesize entryField;
@synthesize toLabel;
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
	
}
- (void)dealloc 
{
	self.addFromAddressBookButton = nil;
	self.entryField = nil;
	self.toLabel = nil;
	self.selectedRecipientCell = nil;

    [super dealloc];
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
	// we're going to loop through all the view looking for RecipientViewCell views and lay them out within this view.
	// If there are no RecipientViewCell then nothing will be changed.  The layout process knows about
	// the three views defined in the xib and will move them as necessary and well as changes the size of this view
	// as needed
	NSInteger neededRows = 1;
	CGPoint	cellLayoutPoint = self.toLabel.frame.origin;
	CGPoint fieldLayoutPoint; 
	
	NSInteger growHeight = self.entryField.frame.size.height;
	
	cellLayoutPoint.x += self.toLabel.frame.size.width + 4;
	NSInteger rightInset = self.addFromAddressBookButton.frame.origin.x - 4;
	
	CGRect subViewRect, frameRect;
	NSInteger layoutViewCount = 0;
	for (UIView *subView in self.subviews)
	{
		if ([subView isKindOfClass:[RecipientViewCell class]])
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
				if (cellLayoutPoint.x + subViewRect.size.width + 4 < self.frame.size.width - 4)
				{
					// it fits in the view so just place it at the layoutPoint
					subViewRect.origin = cellLayoutPoint;
					subViewRect.origin.y += kOriginShift;
					subView.frame = subViewRect;
					cellLayoutPoint.x += subView.frame.size.width + 4;
					
					// we need to move the point to the next line
					cellLayoutPoint.x = kLeftInset;
					cellLayoutPoint.y += growHeight;
					neededRows ++;
				}
				else
				{
					// now we need to see if it will fit on a line all by itself
					if (subViewRect.size.width + 4 < self.frame.size.width)
					{
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
							subViewRect.size.width = self.frame.size.width - cellLayoutPoint.x - 4;
							subView.frame = subViewRect;
							
							cellLayoutPoint.x = kLeftInset;
							cellLayoutPoint.y += growHeight;
							neededRows ++;
						}
						else
						{
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
		}
	}
	
	
	fieldLayoutPoint = cellLayoutPoint;
	
	NSInteger remainingWidth = rightInset - fieldLayoutPoint.x;
	if ( remainingWidth > 150)
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
	
	
	CGFloat newHeight = neededRows * growHeight;
	if ( newHeight > self.defaultHeight )
	{
		frameRect = self.frame;
		frameRect.size.height = self.defaultHeight + ((neededRows-1) * growHeight);
		self.frame = frameRect;
		[self setNeedsDisplay];
		[delegate recipientViewFrameDidChange];
	}
	else
	{
		if (self.frame.size.height > self.defaultHeight)
		{
			frameRect = self.frame;
			frameRect.size.height = self.defaultHeight;
			self.frame = frameRect;
			[self setNeedsDisplay];
			[delegate recipientViewFrameDidChange];
		}
	}
	
	
}


#pragma mark control tracking methods
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	//	BOOL sRet = [super beginTrackingWithTouch:touch withEvent:event];
	BOOL	cellHit = NO;
	for (UIView *subView in self.subviews)
	{
		if ([subView isKindOfClass:[RecipientViewCell class]])
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
		[delegate recipientViewHit];
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

		
		if (cell)
			[delegate recipientViewCellWasSelected:cell];
	}
}

@end
