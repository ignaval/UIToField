//
//  CoreDataDataModel.m
//  UIToField
//
//  Created by ign on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataDataModel.h"
#import "AppDelegate.h"
#import "Contact.h"

@implementation CoreDataDataModel

@dynamic recipients;
@synthesize context = _context;

- (void)contactsResults {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Contact" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@""]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
                              initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    contactsResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_context sectionNameKeyPath:@"nameInitial" cacheName:nil];
    
    //uncomment if you do not want sections
    //contactsResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil];

    
    contactsResults.delegate = self;
    [contactsResults retain];
    
    [sort release];
    [fetchRequest release];
    
    return;
}

-(void)initializeContacts{
    Contact * contact1 = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
    Contact * contact2 = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
    Contact * contact3 = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
    Contact * contact4 = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
    
    contact1.name = @"John";
    contact1.address = @"john@john.com";
    
    contact2.name = @"Joseph";
    contact2.address = @"joseph@joseph.com";
    
    contact3.name = @"Dan";
    contact3.address = @"dan@dan.com";
    
    contact4.name = @"Mary";
    contact4.address = @"mary@mary.com";
    
    NSError *error;
    
    if (![self.context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(id)init{
    if (self = [super init]) 
	{
		if (self.context == nil) 
        { 
            self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
            //NSLog(@"After managedObjectContext: %@",  self.context);
        }
        
        [self contactsResults];
        
        NSError *error;
        
        if (![contactsResults performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        if ([contactsResults.fetchedObjects count] == 0) {
            [self initializeContacts];
            
            if (![contactsResults performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
        
//        NSLog(@"now we have %d contacts loaded",[[contactsResults fetchedObjects] count]);
//        NSLog(@"number of initials = %d",[[contactsResults sectionIndexTitles] count]);
//        NSLog(@"number of sections = %d",[[contactsResults sections] count]);
        
        _recipients = [[NSMutableArray arrayWithCapacity:1] retain];
        foundPeople = [[NSMutableArray array] retain];
	}
	
	return self;
}

-(void)dealloc{
    [super dealloc];
    
    [contactsResults release];
    [_recipients release];
    [foundPeople release];
    
    self.context = nil;
    
}

- (BOOL)foundMatchesForSearchString:(NSString*)searchString{
    [foundPeople removeAllObjects];
    
    for (Contact * c in [contactsResults fetchedObjects]) {
        if ([[c.name lowercaseString] hasPrefix:[searchString lowercaseString]]) {
            [foundPeople addObject:c.name];
        }
    }
    
    [foundPeople sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    return [foundPeople count] > 0;
}

- (NSInteger)countForSearchMatches{
    return [foundPeople count];
}

- (NSInteger)totalContactsCount{
    return [contactsResults.fetchedObjects count];
}

- (NSString*)personNameForIndexPath:(NSIndexPath *)indexP{
    return ((Contact *)[contactsResults objectAtIndexPath:indexP]).name;
}

- (NSString*)personAddressForIndexPath:(NSIndexPath *)indexP{
    return ((Contact *)[contactsResults objectAtIndexPath:indexP]).address;
}

- (NSString*)personNameForIndexInResults:(NSInteger)index{
    return [foundPeople objectAtIndex:index];
}

- (NSString*)personAddressForIndexInResults:(NSInteger)index{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Contact" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",[self personNameForIndexInResults:index]]];
    
    NSError * error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    [fetchRequest release];
    
    if ([fetchedObjects count] > 0) {
        Contact * contact = [fetchedObjects objectAtIndex:0];
        
        return contact.address;
    }
    
    return nil;
}

#pragma mark Recipient List Methods

- (void)addRecipient:(Recipient*)newRecipient;
{
	[_recipients addObject:newRecipient];
}

- (void)removeRecipient:(Recipient*)recipient;
{
	[_recipients removeObject:recipient];
}

- (Recipient*)lastRecipient;
{
	return [_recipients lastObject];
}

- (NSArray*)recipients;
{
	return [[_recipients copy] autorelease];
}

//Comment both methods if you do not want sections
-(NSArray *)contactsInitials{
    return [contactsResults sectionIndexTitles];
}

-(NSInteger)contactsForInitial:(NSString *)initial atIndex:(NSInteger) index{
    return [[[contactsResults sections] objectAtIndex:[contactsResults sectionForSectionIndexTitle:initial atIndex:index]] numberOfObjects];
}

@end
