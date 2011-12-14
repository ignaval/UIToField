//
//  ShadowedTableView.m
//  ShadowedTableView
//
//  Created by Matt Gallagher on 2009/08/21.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import "ShadowedTableView.h"

#define SHADOW_HEIGHT 15.0
#define SHADOW_INVERSE_HEIGHT 10.0
#define SHADOW_RATIO (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT)

@implementation ShadowedTableView

//
// shadowAsInverse:
//
// Create a shadow layer
//
// Parameters:
//    inverse - if YES then shadow fades upwards, otherwise shadow fades downwards
//
// returns the constructed shadow layer
//
- (CAGradientLayer *)shadowAsInverse:(BOOL)inverse
{
	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
	CGRect newShadowFrame =
		CGRectMake(0, 0, self.frame.size.width,
			inverse ? SHADOW_INVERSE_HEIGHT : SHADOW_HEIGHT);
	newShadow.frame = newShadowFrame;
	CGColorRef darkColor =
		[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:
			inverse ? (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT) * 0.5 : 0.3].CGColor;
	CGColorRef lightColor =
		[self.backgroundColor colorWithAlphaComponent:0.0].CGColor;
	newShadow.colors =
		[NSArray arrayWithObjects:
			(id)(inverse ? lightColor : darkColor),
			(id)(inverse ? darkColor : lightColor),
		nil];
	return newShadow;
}

//
// layoutSubviews
//
// Override to layout the shadows when cells are laid out.
//
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	//
	// Construct the origin shadow if needed
	//
	if (!originShadow)
	{
		originShadow = [self shadowAsInverse:NO];
        [self.layer insertSublayer:originShadow above:self.layer];
	}
	else if (![[self.layer.sublayers objectAtIndex:[self.layer.sublayers count] - 1] isEqual:originShadow])
	{
        [self.layer insertSublayer:originShadow above:self.layer];
	}
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	//
	// Stretch and place the origin shadow
	//
	CGRect originShadowFrame = originShadow.frame;
	originShadowFrame.size.width = self.frame.size.width;
	originShadowFrame.origin.y = self.contentOffset.y;
    originShadow.frame = originShadowFrame;
	
	[CATransaction commit];
	
}

- (void)dealloc
{
	[super dealloc];
}


@end
