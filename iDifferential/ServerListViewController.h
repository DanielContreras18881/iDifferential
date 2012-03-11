//
//  ServerListViewController.h
//  iDifferential
//
//  Created by Daniel Fritsch on 19/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerDetailViewController.h"
#import "DataModel.h"

@interface ServerListViewController : UITableViewController <ServerDetailViewControllerDelegate , UINavigationControllerDelegate>

@property (nonatomic, strong) DataModel *dataModel;


@end
