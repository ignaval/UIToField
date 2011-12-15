//
//  ViewController.m
//  SuperTextField
//
//  Created by ign on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "ArrayDataModel.h"
#import "CoreDataDataModel.h"

@implementation ViewController

@synthesize recipientController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //Un comment according to the data model you want to use
        
        //ArrayDataModel * model = [[ArrayDataModel alloc] init];
        CoreDataDataModel * model = [[CoreDataDataModel alloc] init];
        
        recipientController = [[RecipientController alloc] initWithModel:model];
        [model release];
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
    
    [recipientController release];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.recipientController.entryField resignFirstResponder];
}

-(IBAction)showRecipients:(id)sender{
    
    namesAndAddressesLabel.text = @"";
    
    for (Recipient * r in [self.recipientController.model recipients]) {
        namesAndAddressesLabel.text = [namesAndAddressesLabel.text stringByAppendingFormat:@"%@ %@\n",r.recipientName,r.recipientAddress];
        
        NSLog(@"Name: %@ Address: %@",r.recipientName,r.recipientAddress);
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:recipientController.view];
    
    [self.recipientController setUpContactMatchView];
    [self.recipientController setUpNameLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    [self.recipientController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}
//
//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    [self.recipientController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//}

@end
