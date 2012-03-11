//
//  AddTorrentViewController.m
//  iDifferential2
//
//  Created by Daniel Fritsch on 23/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddTorrentViewController.h"
#import "TorrentFileCell.h"
#import "SVProgressHUD.h"



@implementation AddTorrentViewController

@synthesize torrentsArray;
@synthesize torrentNameLabel;
@synthesize torrentManager;



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void) torrentListUpdated: (NSNotification *)notif {
    [SVProgressHUD dismiss];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:52.0/255 green:52.0/255 blue:52.0/255 alpha:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentListUpdated:) name:@"com.dfritsch86.iDifferential.torrentListUpdated" object:nil];
}

- (void)viewDidUnload
{
    [self setTorrentNameLabel:nil];
    self.torrentsArray = nil;
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.dfritsch86.iDifferential.torrentListUpdated" object:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [torrentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TorrentFileCell *cell = (TorrentFileCell *)[tableView dequeueReusableCellWithIdentifier:@"TorrentFileCell"];
    
    UIImage *image = [UIImage imageNamed:@"TableCellGradient"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    cell.backgroundView = backgroundImageView;
    
    NSString *fileName = [[torrentsArray objectAtIndex:indexPath.row] lastPathComponent];
    cell.torrentNameLabel.text = fileName;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *fileName = [torrentsArray objectAtIndex:indexPath.row];
        
        if ([fm removeItemAtPath:fileName error:nil] != YES)
            NSLog(@"Unable to delete file");
        else {
            [torrentsArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }   
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *fileName = [torrentsArray objectAtIndex:indexPath.row];
    NSData *torrentData = [NSData dataWithContentsOfFile:fileName];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    [SVProgressHUD showWithStatus:@"Adding torrent..." networkIndicator:YES];
    
    [torrentManager addTorrentWithSource:torrentData];
    
    
    
}

#pragma mark - IBActions

- (IBAction)dismissAddTorrentView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
