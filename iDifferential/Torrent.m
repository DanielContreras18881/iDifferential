//
//  Torrent.m
//  iDifferential2
//
//  Created by Daniel Fritsch on 23/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Torrent.h"

@implementation Torrent

@synthesize upSpeed, downSpeed, torrentId, name, status, percentDone, isPlaceholder, peersTotal, peersActive, peersDownloading, downloadedData, totalSize, oldStatus, isBlocked;

-(id) initWithDict:(NSDictionary *)dict andIsBlocked: (BOOL)blocked {
    if ((self = [super init])) {
        if(dict != nil) {
            self.torrentId = [[dict objectForKey:@"id"]intValue];
            self.status = [[dict objectForKey:@"status"]intValue];
            self.percentDone = [[dict objectForKey:@"percentDone"]floatValue];
            self.upSpeed = [[dict objectForKey:@"rateUpload"]intValue];
            self.downSpeed = [[dict objectForKey:@"rateDownload"]intValue];
            self.name = [dict objectForKey:@"name"];
            self.peersActive = [[dict objectForKey:@"peersSendingToUs"]intValue];
            self.peersTotal = [[dict objectForKey:@"peersConnected"]intValue];
            self.peersDownloading = [[dict objectForKey:@"peersGettingFromUs"]intValue];
            self.totalSize = [[dict objectForKey:@"totalSize"]intValue];
            self.downloadedData = [[dict objectForKey:@"downloadedEver"]intValue];
            self.isPlaceholder = NO;
            self.isBlocked = blocked;
            self.oldStatus = ([[dict objectForKey:@"percentDone"]floatValue] == 1) ? 6 : 4;
        } else {
            self.name = @"New Torrent...";
            self.torrentId = -1;
            self.isPlaceholder = YES;
            self.isBlocked = YES;
        }
    }
    return self;
}



@end

