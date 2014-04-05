//
//  VirtualClientViewController.m
//  iDifferential
//
//  Created by Daniel Fritsch on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VirtualClientViewController.h"
#import "OverviewCell.h"
#import "DifferentialAppDelegate.h"
#import "AddTorrentViewController.h"
#import "SVProgressHUD.h"


@interface VirtualClientViewController ()

-(void) resumeTimer:(NSTimer *)aTimer;
-(void) pauseTimer:(NSTimer *)aTimer;
-(void) httpCodeChanged;
-(void) updateResumeBar;
-(void) updateToggleButton;
-(void) torrentListUpdated: (NSNotification *)notif;

@end


@implementation VirtualClientViewController {
    NSMutableArray *torrentsInTransmission;
    BOOL isPaused;
    NSIndexPath *lastIndexPath;
    NSDate *pauseStart, *previousFireDate;
    BOOL firstRun;
    
}




@synthesize server;
@synthesize numbersOfTransferLabel;
@synthesize upDownSpeedLabel;
@synthesize statusBarView;
@synthesize startButton;
@synthesize pauseButton;
@synthesize addTorrentButton;
@synthesize refreshButton;
@synthesize torrentManager;
@synthesize timer;



#pragma mark - View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Starting NEW VIRTUAL CLIENT");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentListUpdated:) name:@"com.dfritsch86.iDifferential.torrentListUpdated" object:nil];
    self.torrentManager = [[TorrentManager alloc] initWithServer:self.server];
    self.tableView.backgroundColor = [UIColor colorWithRed:52.0/255 green:52.0/255 blue:52.0/255 alpha:1];
    self.statusBarView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"StatusbarGradient"]];
    self.title = self.server.description;
    [SVProgressHUD showWithStatus:@"Connecting..." networkIndicator:YES];
    self->firstRun = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(server.refreshRate > 0) {
        //NSLog(@"Refreshing");
        timer = [NSTimer scheduledTimerWithTimeInterval:server.refreshRate target:self selector:@selector(refreshTorrentData:) userInfo:nil repeats:YES];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //we need to run only here, in order to pop if network error
    //and we don't want to get new infos when dismissing the add torrent view
    if(self->firstRun) {
        [self.torrentManager getBasicTorrentInfo];
        self->firstRun = NO;
    }
    
}

/*-(void) dealloc {

    NSLog(@"Virtual client dealloc");
    NSLog(@"Deleting VIRTUAL CLIENT");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.dfritsch86.iDifferential.torrentListUpdated" object:nil];
    
    [self setNumbersOfTransferLabel:nil];
    [self setServer:nil];
    [self setUpDownSpeedLabel:nil];
    [self setStartButton:nil];
    [self setPauseButton:nil];
    [self setTorrentManager:nil];
    [self setAddTorrentButton:nil];
    [self setRefreshButton:nil];
    [self setStatusBarView:nil];
}*/

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    
     NSLog(@"Deleting VIRTUAL CLIENT");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.dfritsch86.iDifferential.torrentListUpdated" object:nil];
    
    [self setNumbersOfTransferLabel:nil];
    [self setServer:nil];
    [self setUpDownSpeedLabel:nil];
    [self setStartButton:nil];
    [self setPauseButton:nil];
    [self setTorrentManager:nil];
    [self setAddTorrentButton:nil];
    [self setRefreshButton:nil];
    [self setStatusBarView:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([timer isValid]) {
        [timer invalidate];
    }
    [SVProgressHUD dismiss];
    
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.torrentManager.torrentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OverviewCell *cell = (OverviewCell *)[tableView dequeueReusableCellWithIdentifier:@"TorrentDetailCell"];
    
    Torrent *currentTorrent = (Torrent *) [self.torrentManager.torrentList objectAtIndex:indexPath.row];
    
    
    int upSpeed         = currentTorrent.upSpeed / 1000.0;
    int downSpeed       = currentTorrent.downSpeed / 1000.0;
    CGFloat percentDone = currentTorrent.percentDone * 100.0;
    CGFloat totalSize   = currentTorrent.totalSize / 1000000.0;
    CGFloat downSize    = currentTorrent.downloadedData / 1000000.0;
    int status = currentTorrent.status;
    UIColor *barColor;
    
    BOOL placeholder = currentTorrent.isPlaceholder;
    BOOL isBlocked = currentTorrent.isBlocked;
    
    NSString *downloadedString;
    NSString *peersString;
    NSString *speedString;
    NSString *nameString;
    UIImage *image;
    
    
    
    if (placeholder) {
        image = [UIImage imageNamed:@"CellGradientSpecialState"];
        nameString = @"Torrent added...";
        downloadedString = @"Wait or manually refresh for it to appear";
        speedString = @"On slow connections it may briefly disappear, just wait...";
        
    } else if (isBlocked) {
        image = [UIImage imageNamed:@"CellGradientSpecialState"];
        nameString = currentTorrent.name;
        downloadedString = @"Torrent is blocked by previous operation";
        speedString = @"On slow connections this might take a while";
        barColor = [UIColor grayColor];
        
    } else {
       
        image = [UIImage imageNamed:@"TableCellGradient"];
        downloadedString = [NSString stringWithFormat:@"%0.2f MB of %0.2f MB  (%0.2f%%)", downSize, totalSize, percentDone];
        peersString = [NSString stringWithFormat:@"Downloading from %d of %d peers", currentTorrent.peersActive, currentTorrent.peersTotal];
        speedString = [NSString stringWithFormat:@"UL: %d kB/s, DL: %d kB/s", upSpeed, downSpeed];
        nameString = currentTorrent.name;
        
        
        if(status == 0) {
            //torrent is paused
            barColor = [UIColor grayColor];
            peersString = @"";
            speedString = @"Download is currently paused";
            
        } else if (status == 1) {
            //queued for checking files
            barColor = [UIColor colorWithRed:198.0/255 green:168.0/255 blue:3.0/255 alpha:1];
            
        } else if (status == 2) {
            //checking files
            barColor = [UIColor colorWithRed:198.0/255 green:168.0/255 blue:3.0/255 alpha:1];
            
        } else if (status == 3) {
            //queued for download
            barColor = [UIColor colorWithRed:1.0/255 green:103.0/255 blue:181.0/255 alpha:1];
            
        } else if (status == 4) {
            //downloading
            barColor = [UIColor colorWithRed:1.0/255 green:103.0/255 blue:181.0/255 alpha:1];
            
        } else if (status == 5) {
            //queued for seeding
            barColor = [UIColor colorWithRed:2.0/255 green:156.0/255 blue:2.0/255 alpha:1];
            
        } else if (status == 6) {
            //seeding
            barColor = [UIColor colorWithRed:2.0/255 green:156.0/255 blue:2.0/255 alpha:1];
            //inverted on pourpose, so that the string is on the left
            speedString = [NSString stringWithFormat:@"Seeding towards %d of %d peers  -  UL: %d kB/s", currentTorrent.peersDownloading, currentTorrent.peersTotal, upSpeed];
            peersString = @"";
        }
    
    }
    
    
    cell.downloadedLabel.text = downloadedString;
    cell.peersLabel.text = peersString;
    cell.upDownLabel.text = speedString;
    cell.nameLabel.text = nameString;
    cell.progressLabel.progressTintColor = barColor;
    [cell.progressLabel setProgress:currentTorrent.percentDone];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    cell.backgroundView = backgroundImageView;
    
    
    return cell;

}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Torrent *currentTorrent = [self.torrentManager.torrentList objectAtIndex:indexPath.row];
    [torrentManager toggleStartStopTorrents:currentTorrent];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Torrent *tempTorrent = [torrentManager.torrentList objectAtIndex:indexPath.row];
    if (tempTorrent.isBlocked || tempTorrent.isPlaceholder) {
        return nil;
    } else {
        return indexPath;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Torrent *tempTorrent = [torrentManager.torrentList objectAtIndex:indexPath.row];
    if (tempTorrent.isBlocked || tempTorrent.isPlaceholder) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self pauseTimer:timer];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resumeTimer:timer];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self->lastIndexPath = indexPath;
        UIActionSheet *deleteFile = [[UIActionSheet alloc] initWithTitle:@"Delete Download" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Data" otherButtonTitles: @"Keep Data", nil];
        deleteFile.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [deleteFile showInView:[[[UIApplication sharedApplication] delegate] window]];
    }   
}



#pragma mark - IBActions

-(IBAction)toggleStartStopTorrents:(id)sender  {
    [torrentManager toggleStartStopTorrents:nil];
}

-(IBAction) refreshTorrentData:(id)sender  {
    [torrentManager getBasicTorrentInfo];
}

- (IBAction)addNewTorrent:(id)sender {
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Add Torrent" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add from Clipboard", @"Add from File", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [popupQuery showInView: [[[UIApplication sharedApplication] delegate] window]];
}


- (IBAction)stopDownload:(id)sender {
    [torrentManager stopAllTorrents];
}


- (IBAction)startDownload:(id)sender {
    [torrentManager startAllTorrents];
}


#pragma mark - UI Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet.title isEqualToString:@"Add Torrent"]) {
        //NSLog(@"Sheet: %@", actionSheet.title);
        if (buttonIndex == 0) {
            //NSLog(@"Clipboard");
            @try {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                NSString *string = pasteboard.string;
                
                if([string hasSuffix:@".torrent"] && [string hasPrefix:@"http"]) {
                    //NSLog(@"FOUND TORRENT");
                    [torrentManager addTorrentWithSource:string];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The content of the clipboard doesn't seem to point to a valid torrent url" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
            }
            @catch (NSException *exception) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The content of the clipboard doesn't seem to point to a valid torrent url" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                
            }
            
        } else if (buttonIndex == 1) {
            //NSLog(@"File");
            
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *inboxDirectory = [documentsDirectory stringByAppendingPathComponent:@"Inbox"];
            NSArray *inboxContent = [fm contentsOfDirectoryAtPath:inboxDirectory error:nil];
            NSMutableArray *torrentListWithPaths = [[NSMutableArray alloc] initWithCapacity:1];
            for(NSString *fileName in inboxContent) {
                [torrentListWithPaths addObject: [inboxDirectory stringByAppendingPathComponent:fileName]];
            }
            
            [self performSegueWithIdentifier:@"OpenFileNavigator" sender:torrentListWithPaths];
            
        } else if (buttonIndex == 2) {
            //NSLog(@"Cancel");
        }
    } 
    
    
    else if ([actionSheet.title isEqualToString:@"Delete Download"]) {
        NSLog(@"Sheet: %@", actionSheet.title);
        Torrent *currentTorrent = [torrentManager.torrentList objectAtIndex: self->lastIndexPath.row];
        if (buttonIndex == 0) {
            [torrentManager deleteTorrentAndData:currentTorrent];
        } else if (buttonIndex == 1) {
            [torrentManager deleteTorrentNotData:currentTorrent];
        }
    }
}





#pragma mark - Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OpenFileNavigator"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddTorrentViewController *controller = (AddTorrentViewController *)navigationController.topViewController;
        controller.torrentsArray = sender;
        controller.torrentManager = self.torrentManager;
    }
}




- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Timer pause resume

-(void) pauseTimer:(NSTimer *)aTimer { 
    
    //Removing observer cause on slow connections there could be items on the queue
    //that would trigger an automatic refresh
    
    pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    previousFireDate = [aTimer fireDate];
    [aTimer setFireDate:[NSDate distantFuture]];
}

-(void) resumeTimer:(NSTimer *)aTimer {
    
    float pauseTime = -1*[pauseStart timeIntervalSinceNow];
    [aTimer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
    pauseStart = nil;
    previousFireDate = nil;
}


#pragma mark - Notification Function and View Update


-(void) updateResumeBar {
    self.numbersOfTransferLabel.text = [NSString stringWithFormat:@"%i Transfers", [torrentManager.torrentList count]];
    self.upDownSpeedLabel.text = [NSString stringWithFormat:@"UL: %d kB/s  DL: %d kB/s", torrentManager.upSpeed, torrentManager.downSpeed];
}

-(void) updateToggleButton {
    if (torrentManager.somePausedTorrents) {
        [self.startButton setEnabled:YES ];
    } else {
        [self.startButton setEnabled:NO ];
    }
    
    if (torrentManager.someActiveTorrents) {
        [self.pauseButton setEnabled:YES];
    } else {
        [self.pauseButton setEnabled:NO ];
    }
    
    [self.addTorrentButton setEnabled:YES];
    [self.refreshButton setEnabled:YES];
    
}

-(void) torrentListUpdated: (NSNotification *)notif {
    
    //TODO: in the future, use notif to selectively update the row
    //NSLog(@"Received Notification, updating table");
    [self updateResumeBar];
    [self updateToggleButton];
    [self httpCodeChanged];
    
    //[SVProgressHUD dismiss];
    
    [self.tableView reloadData];
    
}



-(void) httpCodeChanged {
    if (torrentManager.httpCode == 200) {
        [SVProgressHUD dismiss];
    } else if (torrentManager.httpCode == 401) {
        
        NSLog(@"VIEW CONTROLLER SAYS: connection error 401");
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"Wrong Password");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to login. Verify username and password again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
          
    } else if (torrentManager.httpCode == 0) {
        
        NSLog(@"VIEW CONTROLLER SAYS: connection error 0");
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"Transmission not running");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There doesn't seem to be an instance of Transmission at the specified address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSLog(@"VIEW CONTROLLER SAYS: connection error unspecified");
    }
}


@end
