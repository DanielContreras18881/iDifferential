//
//  VirtualClientViewController.h
//  iDifferential
//
//  Created by Daniel Fritsch on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerSettings.h"
#import "TorrentManager.h"
#import "Torrent.h"

@interface VirtualClientViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) ServerSettings *server;
@property (nonatomic, strong) TorrentManager *torrentManager;
@property (strong, nonatomic) IBOutlet UILabel *numbersOfTransferLabel;
@property (strong, nonatomic) IBOutlet UILabel *upDownSpeedLabel;
@property (strong, nonatomic) IBOutlet UIView *statusBarView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *startButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addTorrentButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) NSTimer *timer;  //should be ivar



- (IBAction) refreshTorrentData:(id)sender;
- (IBAction) addNewTorrent:(id)sender;
- (IBAction) startDownload:(id)sender;
- (IBAction) stopDownload:(id)sender;


@end
