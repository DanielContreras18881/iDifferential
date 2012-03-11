//
//  ServerDetailViewController.h
//  iDifferential
//
//  Created by Daniel Fritsch on 19/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController;
@class ServerSettings;

@protocol ServerDetailViewControllerDelegate <NSObject>


-(void)serverDetailViewControllerDidCancel:(ServerDetailViewController *)controller;
-(void)serverDetailViewController:(ServerDetailViewController *)controller didFinishAddingServer:(ServerSettings *) item;
- (void)serverDetailViewController:(ServerDetailViewController *)controller didFinishEditingServer:(ServerSettings *)item;


@end

@interface ServerDetailViewController : UITableViewController

@property (weak, nonatomic) id<ServerDetailViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *descriptionText;
@property (strong, nonatomic) IBOutlet UITextField *addressText;
@property (strong, nonatomic) IBOutlet UITextField *portText;
@property (strong, nonatomic) IBOutlet UITextField *usernameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UITextField *secondsText;

@property (strong, nonatomic) ServerSettings *serverToEdit;


-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;

@end
