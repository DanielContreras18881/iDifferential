//
//  ServerListViewController.m
//  iDifferential
//
//  Created by Daniel Fritsch on 19/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerListViewController.h"
#import "ServerSettings.h"
#import "VirtualClientViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation ServerListViewController

@synthesize dataModel;




#pragma mark - Inits

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.dataModel = [[DataModel alloc] init];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:52.0/255 green:52.0/255 blue:52.0/255 alpha:1];    
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
    
	self.navigationController.delegate = self;
    
	int index = [self.dataModel indexOfSelectedServer];
    
	if (index >= 0 && index < [self.dataModel.serverList count]) {
		ServerSettings *server = [self.dataModel.serverList objectAtIndex:index];
		[self performSegueWithIdentifier:@"OpenClient" sender:server];
	}
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModel.serverList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServerListItem"];
      
    
    ServerSettings *server = [self.dataModel.serverList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = server.description;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%d", server.url, server.port];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.dataModel.serverList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ServerSettings *server = [self.dataModel.serverList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EditServer" sender:server];
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataModel setIndexOfSelectedServer:indexPath.row];
    
	ServerSettings *server = [self.dataModel.serverList objectAtIndex:indexPath.row];
	[self performSegueWithIdentifier:@"OpenClient" sender:server];
}

#pragma mark - ServerDetails Delegate

-(void) serverDetailViewControllerDidCancel:(ServerDetailViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];

}


-(void) serverDetailViewController:(ServerDetailViewController *)controller didFinishAddingServer:(ServerSettings *)server {

    int newRowIndex = [self.dataModel.serverList count];
    [self.dataModel.serverList addObject:server];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) serverDetailViewController:(ServerDetailViewController *)controller didFinishEditingServer:(ServerSettings *)server {
    
    
    int index = [self.dataModel.serverList indexOfObject:server];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.text = server.description;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%d", server.url, server.port];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddServer"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ServerDetailViewController *controller = (ServerDetailViewController *)navigationController.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"EditServer"]) {
        NSLog(@"EDIT");
        UINavigationController *navigationController = segue.destinationViewController;
        ServerDetailViewController *controller = (ServerDetailViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.serverToEdit = sender;
        NSLog(@"Server to edit: %@", sender);
    } else if ([segue.identifier isEqualToString:@"OpenClient"]) {
		VirtualClientViewController *virtualClient = (VirtualClientViewController *)segue.destinationViewController;
        
        // Pass the data for the selected Server
        virtualClient.server = sender;
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (viewController == self) {
		[self.dataModel setIndexOfSelectedServer:-1];
	}
}


@end
