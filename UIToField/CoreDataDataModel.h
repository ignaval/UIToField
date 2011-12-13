//
//  CoreDataDataModel.h
//  UIToField
//
//  Created by ign on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecipientController.h"

@interface CoreDataDataModel : NSObject <DataModelDelegate, NSFetchedResultsControllerDelegate>{
    NSManagedObjectContext *_context;
    
    NSFetchedResultsController * contactsResults;
    
    NSMutableArray * _recipients;
    NSMutableArray * foundPeople;
}

@property (nonatomic, retain) NSManagedObjectContext *context;

@end
