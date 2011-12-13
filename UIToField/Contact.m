//
//  Contact.m
//  UIToField
//
//  Created by ign on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@dynamic name;
@dynamic address;
@dynamic nameInitial;

- (NSString *) nameInitial {
    [self willAccessValueForKey:@"nameInitial"];
    NSString * initial = [[[self name] substringToIndex:1] uppercaseString];
    [self didAccessValueForKey:@"nameInitial"];
    return initial;
}

@end
