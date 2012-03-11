//
//  RequestHandler.h
//  iDifferential
//
//  Created by Daniel Fritsch on 21/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCClient.h"
#import "ServerSettings.h"
#import "Torrent.h"


@interface TorrentManager : NSObject <RPCClientDelegate>

@property (strong, nonatomic) NSMutableArray *torrentList;
@property (nonatomic) BOOL somePausedTorrents;
@property (nonatomic) BOOL someActiveTorrents;
@property (nonatomic) int upSpeed;
@property (nonatomic) int downSpeed;
@property (nonatomic) int httpCode;


- (id)initWithServer:(ServerSettings *)aServer;


#pragma mark - New TorrentManager

-(void) getBasicTorrentInfo;
-(void) toggleStartStopTorrents: (Torrent *) torrentToToggle;
-(void) deleteTorrentNotData: (Torrent *) torrentToDelete;
-(void) deleteTorrentAndData: (Torrent *) torrentToDelete;
-(void) stopAllTorrents;
-(void) startAllTorrents;
-(void) addTorrentWithSource: (id) source;

@end
