//
//  DifferentialAppDelegate.m
//  iDifferential
//
//  Created by Daniel Fritsch on 19/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DifferentialAppDelegate.h"
#import "ServerListViewController.h"

@implementation DifferentialAppDelegate

@synthesize window = _window;


- (void)saveData
{
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    ServerListViewController *controller = (ServerListViewController *)[navigationController.viewControllers objectAtIndex:0];
    [controller.dataModel saveServerList];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Torrent Added" message:@"The torrent has succesfully been added. To start download, connect to Transmission and add it from file" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alert show];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self saveData];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveData];
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
