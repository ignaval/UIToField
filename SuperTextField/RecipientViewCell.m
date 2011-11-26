//
//  RecipientViewCell.m
//  MultiRecipientPicker
//
//  Created by Joe Michels on 5/14/10.
//  Copyright 2010 Software Ops LLC. All rights reserved.
//

#import "RecipientViewCell.h"
#define	kHorzInset	6
#define	kVertInset	2
#define kFontSize   15.0
#define kTextShift  3

#define kNormalStrokeColor [UIColor colorWithRed:121/256.0 green:133/256.0 blue:217/256.0 alpha:1]
#define kNormalGradientTop [UIColor colorWithRed:221/256.0 green:231/256.0 blue:248/256.0 alpha:1]
#define kNormalGradientBottom [UIColor colorWithRed:188/256.0 green:206/256.0 blue:241/256.0 alpha:1]

#define kSelectedStrokeColor [UIColor colorWithRed:53/256.0 green:94/256.0 blue:255/256.0 alpha:1]
#define kSelectedGradientTop [UIColor colorWithRed:79/256.0 green:144/256.0 blue:255/256.0 alpha:1]
#define kSelectedGradientBottom [UIColor colorWithRed:49/256.0 green:90/256.0 blue:255/256.0 alpha:1]

@implementation RecipientViewCell

@dynamic cellDisplayTitle;
@synthesize titleSize;


- (id)initWithTitle:(NSString*)title 
{
    if ((self = [super initWithFrame:CGRectZero])) 
	{
        // Initialization code
		self.cellDisplayTitle = title;
		UIFont	*textFont = [UIFont systemFontOfSize:kFontSize];
		CGSize textSize = [self.cellDisplayTitle sizeWithFont:textFont];
		self.titleSize = textSize;
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		
		
		textSize.width += kHorzInset*2; 
		self.frame = CGRectMake(0, 0, (textSize.width > 34) ? textSize.width : 34, 25);
    }
    return self;
}

- (void)dealloc 
{
	self.cellDisplayTitle = nil;
	
    [super dealloc];
}

- (void)drawRect:(CGRect)rect 
{
	
	CGRect buttonRect = CGRectInset(rect, 1.0, 1.0);
	buttonRect = CGRectOffset(buttonRect, 0.5, 0.5);
	
	CGRect textRect = rect;

	if (titleSize.width < rect.size.width)
	{
		textRect.origin.x = (rect.size.width - titleSize.width)/2;
		textRect.origin.y += kTextShift;
		textRect.size.width = titleSize.width;
	}
	else
	{
		textRect = CGRectInset(textRect, 6, 0);
		textRect.origin.y += kTextShift;
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();	

	CGContextSaveGState(context);

	CGFloat radius = buttonRect.size.height/2;
	CGMutablePathRef buttonPath = CGPathCreateMutable();
	
	CGFloat minx = CGRectGetMinX(buttonRect), midx = CGRectGetMidX(buttonRect), maxx = CGRectGetMaxX(buttonRect);
	CGFloat miny = CGRectGetMinY(buttonRect), midy = CGRectGetMidY(buttonRect), maxy = CGRectGetMaxY(buttonRect);
	
	
    CGPathMoveToPoint(buttonPath, nil, minx, midy);
    CGPathAddArcToPoint(buttonPath, nil, minx, miny, midx, miny, radius);
    CGPathAddArcToPoint(buttonPath, nil, maxx, miny, maxx, midy, radius);
    CGPathAddArcToPoint(buttonPath, nil, maxx, maxy, midx, maxy, radius);
    CGPathAddArcToPoint(buttonPath, nil, minx, maxy, minx, midy, radius);
    CGPathCloseSubpath(buttonPath);
	
	
	CGContextAddPath (context, buttonPath);
		

	if (self.selected)
	{
		CGContextSaveGState(context);
		CGContextClip (context);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		CGGradientRef buttonGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)[NSArray arrayWithObjects:(id)kSelectedGradientTop.CGColor, (id)kSelectedGradientBottom.CGColor, nil], NULL); //locations -  NULL means  evenly distribute
		
		CGContextDrawLinearGradient(context, buttonGradient, 
									CGPointMake(buttonRect.origin.x, buttonRect.origin.y), 
									CGPointMake(buttonRect.origin.x, 
												buttonRect.origin.y + buttonRect.size.height), 
									
									0/*options*/);
		CFRelease(buttonGradient);
		CGColorSpaceRelease(colorSpace);
		
		CGContextRestoreGState(context);
		
		CGContextAddPath (context, buttonPath);
		[kSelectedStrokeColor set];
		CGContextStrokePath(context);
		
		
		[[UIColor whiteColor] set];
//		[self.cellImageSelected drawInRect:rect];
		[self.cellDisplayTitle drawInRect:textRect withFont:[UIFont systemFontOfSize:kFontSize] lineBreakMode:UILineBreakModeTailTruncation];
	}
	else
	{
		CGContextSaveGState(context);
		CGContextClip (context);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		CGGradientRef buttonGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)[NSArray arrayWithObjects:(id)kNormalGradientTop.CGColor, (id)kNormalGradientBottom.CGColor, nil], NULL); //locations -  NULL means  evenly distribute
		
		CGContextDrawLinearGradient(context, buttonGradient, 
									CGPointMake(buttonRect.origin.x, buttonRect.origin.y), 
									CGPointMake(buttonRect.origin.x, 
												buttonRect.origin.y + buttonRect.size.height), 
									
									0/*options*/);
		CFRelease(buttonGradient);
		CGColorSpaceRelease(colorSpace);
		
		CGContextRestoreGState(context);
		
		CGContextAddPath (context, buttonPath);
		[kNormalStrokeColor set];
		CGContextStrokePath(context);
		
		[[UIColor blackColor] set];
		
//		[self.cellImageNormal drawInRect:rect];
		[self.cellDisplayTitle drawInRect:textRect withFont:[UIFont systemFontOfSize:kFontSize] lineBreakMode:UILineBreakModeTailTruncation];
	}
	
	CGContextRestoreGState(context);

	CGPathRelease(buttonPath);

}



- (NSString*)cellDisplayTitle;
{
	return cellDisplayTitle;
}

- (void)setCellDisplayTitle:(NSString *)title;
{
	[cellDisplayTitle release];
	
	if (title)
	{
		NSScanner *titleScanner = [NSScanner scannerWithString:title];
		
		if ( [titleScanner scanUpToString:@"<" intoString:&cellDisplayTitle] == NO )
		{
			cellDisplayTitle = nil;
		}
		
		[cellDisplayTitle retain];
	}
	else
	{
		cellDisplayTitle =  title;
	}


}

@end
