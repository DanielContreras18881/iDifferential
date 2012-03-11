//
//  AddTorrentViewController.h
//  iDifferential2
//
//  Created by Daniel Fritsch on 23/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TorrentManager.h"

@interface AddTorrentViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *torrentsArray;
@property (strong, nonatomic) TorrentManager *torrentManager;
@property (strong, nonatomic) IBOutlet UILabel *torrentNameLabel;

- (IBAction)dismissAddTorrentView:(id)sender;

@end
