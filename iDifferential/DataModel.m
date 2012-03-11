//
//  DataModel.m
//  iDifferential
//
//  Created by Daniel Fritsch on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "DataModel.h"
#import "ServerSettings.h"

@implementation DataModel

@synthesize serverList;

- (NSString *)documentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

- (NSString *)dataFilePath
{
	return [[self documentsDirectory] stringByAppendingPathComponent:@"Checklists.plist"];
}

- (void)saveServerList
{
    //NSLog(@"Saving Data");
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:serverList forKey:@"ServerList"];
	[archiver finishEncoding];
	[data writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadServerList
{
    //NSLog(@"Loading Data");
	NSString *path = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSData *data = [[NSData alloc] initWithContentsOfFile:path];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		serverList = [unarchiver decodeObjectForKey:@"ServerList"];
		[unarchiver finishDecoding];
	} else {
		serverList = [[NSMutableArray alloc] initWithCapacity:20];
	}
}

- (void)registerDefaults
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:-1], @"ServerIndex",
                                [NSNumber numberWithBool:YES], @"FirstTime",
                                nil];
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

- (void)handleFirstTime
{
	BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
	if (firstTime) {
		//Configure First Run
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
	}
}

- (id)init
{
	if ((self = [super init])) {
		[self loadServerList];
		[self registerDefaults];
		[self handleFirstTime];
	}
	return self;
}

- (int)indexOfSelectedServer
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"ServerIndex"];
}

- (void)setIndexOfSelectedServer:(int)index
{
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"ServerIndex"];
}



@end
