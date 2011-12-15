//
//  ViewController.h
//  SuperTextField
//
//  Created by ign on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipientController.h"

@interface ViewController : UIViewController{
    
    RecipientController * recipientController;
    
    IBOutlet UILabel * namesAndAddressesLabel;
    
}

@property (nonatomic, retain) RecipientController	*recipientController;

@end
