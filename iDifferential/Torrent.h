//
//  Torrent.h
//  iDifferential2
//
//  Created by Daniel Fritsch on 23/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Torrent : NSObject

@property (nonatomic) BOOL isPlaceholder;
@property (nonatomic) BOOL isBlocked;
@property (nonatomic) int torrentId;
@property (nonatomic) int downSpeed;
@property (nonatomic) int upSpeed;
@property (nonatomic) int status;
@property (nonatomic) CGFloat percentDone;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) int totalSize;
@property (nonatomic) int downloadedData;
@property (nonatomic) int peersTotal;
@property (nonatomic) int peersActive;
@property (nonatomic) int peersDownloading;
@property (nonatomic) int oldStatus;


-(id) initWithDict: (NSDictionary *) dict andIsBlocked: (BOOL)blocked;
@end
