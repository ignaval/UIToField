//
//  ArrayDataModel.h
//  SuperTextField
//
//  Created by ign on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface ArrayDataModel : NSObject <DataModelDelegate>{
    NSMutableArray * _recipients;
    NSDictionary * contacts;
    NSMutableArray * foundPeople;
}

@property (nonatomic, retain) NSMutableArray *foundPeople;

@end
