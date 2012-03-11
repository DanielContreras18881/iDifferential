//
//  ServerDetailViewController.m
//  iDifferential
//
//  Created by Daniel Fritsch on 19/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerDetailViewController.h"
#import "ServerSettings.h"


@implementation ServerDetailViewController

@synthesize delegate;
@synthesize descriptionText;
@synthesize addressText;
@synthesize portText;
@synthesize usernameText;
@synthesize passwordText;
@synthesize secondsText;
@synthesize serverToEdit;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    if (self.serverToEdit != nil) {
        self.title = @"Edit Server";
        self.addressText.text = self.serverToEdit.url;
        self.descriptionText.text = self.serverToEdit.description;
        self.portText.text = [NSString stringWithFormat:@"%d", self.serverToEdit.port];
        self.usernameText.text = self.serverToEdit.username;
        self.passwordText.text = self.serverToEdit.password;
        self.secondsText.text = [NSString stringWithFormat:@"%d", self.serverToEdit.refreshRate];
    }

   
}

- (void)viewDidUnload
{
    [self setDescriptionText:nil];
    [self setAddressText:nil];
    [self setPortText:nil];
    [self setUsernameText:nil];
    [self setPasswordText:nil];
    [self setSecondsText:nil];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - IBActions

-(IBAction)cancel:(id)sender {

     NSLog(@"Cancel");
    [self.delegate serverDetailViewControllerDidCancel:self];
    
}


-(IBAction)done:(id)sender{
    
    NSLog(@"Done");
    
    int port = [self.portText.text integerValue];
    int rate = [self.secondsText.text integerValue];
    
    NSLog(@"Port: %d and rate: %d", port, rate);
    
    
    if([self.addressText.text hasPrefix:@"http://"]) {
        NSRange rangeOfPrefix = [self.addressText.text rangeOfString:@"http://"];
        self.addressText.text = [self.addressText.text stringByReplacingCharactersInRange:rangeOfPrefix withString:@""];
    }
    
    if (port < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Port number must be positve.\n Stadard port is 9091" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    } else if (rate < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Refresh rate must be positve amount of seconds." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
       
    
    if (self.serverToEdit == nil) {
        ServerSettings *server = [[ServerSettings alloc] init];
        server.description = self.descriptionText.text;
        server.url = self.addressText.text;
        server.port = port;
        server.username = self.usernameText.text;
        server.password = self.passwordText.text;
        server.refreshRate = rate;
        
        [self.delegate serverDetailViewController:self didFinishAddingServer:server];
    } else {
        self.serverToEdit.description = self.descriptionText.text;
        self.serverToEdit.url = self.addressText.text;
        self.serverToEdit.port = port;
        self.serverToEdit.username = self.usernameText.text;
        self.serverToEdit.password = self.passwordText.text;
        self.serverToEdit.refreshRate = rate;
        
        
        [self.delegate serverDetailViewController:self didFinishEditingServer:self.serverToEdit];
    }
    
}

@end
