//
//  RequestHandler.m
//  iDifferential
//
//  Created by Daniel Fritsch on 21/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TorrentManager.h"
#import "RPCClient.h"
#import "Base64Encoding.h"

//Private Methods
@interface TorrentManager ()

-(NSMutableArray *) trasformResultInTorrentArray: (NSArray *) resultArray; 
-(void) checkForSomeActivePausedTorrents;
-(void) performActionOnTorrents: (NSString *) requestedAction andEventuallyTorrent:(Torrent *) requestedTorrent;
-(void) deleteTorrent: (Torrent *) torrentToDelete deleteData:(BOOL)wantToDelete;   
-(void) blockTorrentForCurrentTag: (NSMutableArray *)torrentsToBlock;
-(void) removeBlocksForTorrentOfTag:(NSNumber *) tag;
-(NSArray *) getTorrentsForTag: (NSNumber *) tag;
-(void) sendCommandwithMethod: (NSString *) method andArguments: (NSMutableDictionary *) argsDict;

@end




@implementation TorrentManager {
    ServerSettings *server;
    RPCClient *rpcClient;
    NSMutableArray *blockedTorrentIds;
    NSMutableDictionary *tagBlocksTorrents;
    int currentTag;
}

@synthesize torrentList;
@synthesize somePausedTorrents;
@synthesize someActiveTorrents;
@synthesize upSpeed;
@synthesize downSpeed;
@synthesize httpCode;

- (id)initWithServer:(ServerSettings *)aServer {
    if ((self = [super init])) {
        self->server = aServer;
        self->rpcClient = [[RPCClient alloc] initWithServer:server andDelegate:self];
        someActiveTorrents=NO;
        somePausedTorrents=NO;
        httpCode = 200;
        upSpeed = 0;
        downSpeed = 0;
        blockedTorrentIds = [NSMutableArray array];
        tagBlocksTorrents = [NSMutableDictionary dictionary];
        torrentList = [NSMutableArray array];
        currentTag = 0;
    }
    
    return self;
}





-(void) getBasicTorrentInfo {
    
    NSMutableArray *fieldsArray = [NSMutableArray arrayWithObjects:
                                   @"name", 
                                   @"percentDone", 
                                   @"rateUpload", 
                                   @"rateDownload", 
                                   @"id", 
                                   @"status", 
                                   @"totalSize", 
                                   @"downloadedEver", 
                                   @"peersConnected", 
                                   @"peersSendingToUs", 
                                   @"peersGettingFromUs", 
                                   nil];
    NSMutableDictionary *argumentsDict = [NSMutableDictionary dictionaryWithObject:fieldsArray forKey:@"fields"];
    
    [self sendCommandwithMethod:@"torrent-get" andArguments:argumentsDict];
}


#pragma mark - Start / Pause Torrents

-(void) performActionOnTorrents: (NSString *) requestedAction andEventuallyTorrent:(Torrent *) requestedTorrent {
    
    NSMutableDictionary *argumentsForCommand = [NSMutableDictionary dictionary];
    NSMutableArray *torrentsToBlock = [NSMutableArray array];
    
    if(requestedTorrent != nil) {
        NSNumber *idNumber = [NSNumber numberWithInt:requestedTorrent.torrentId];
        NSArray *idArray = [NSArray arrayWithObject:idNumber];
        if([blockedTorrentIds containsObject:idNumber]) {
            NSLog(@"ACTION ON BLOCKED ELEMENT");
            return;
        }
        [argumentsForCommand setObject:idArray forKey:@"ids"];
        [torrentsToBlock addObject:requestedTorrent];
        
    
    } else {
        
        NSMutableArray *clearedTorrentsId = [NSMutableArray array];
        NSMutableArray *clearedTorrents = [NSMutableArray array];
        
        for(Torrent *currentTorrent in torrentList) {
            NSNumber *idNumber = [NSNumber numberWithInt:currentTorrent.torrentId];
            if(![blockedTorrentIds containsObject:idNumber]) {
                [clearedTorrentsId addObject:idNumber];
                [clearedTorrents addObject:currentTorrent];
            }
        }
        
        [argumentsForCommand setObject:clearedTorrentsId forKey:@"ids"];
        torrentsToBlock = clearedTorrents;
        
    }
    
    [self blockTorrentForCurrentTag:torrentsToBlock];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.dfritsch86.iDifferential.torrentListUpdated" object:self];
    [self sendCommandwithMethod:requestedAction andArguments:argumentsForCommand]; 
    
}

-(void) toggleStartStopTorrents: (Torrent *) torrentToToggle{

    NSString *requestedAction = (torrentToToggle.status == 0) ? @"torrent-start" : @"torrent-stop";
    [self performActionOnTorrents:requestedAction andEventuallyTorrent:torrentToToggle];
}

-(void) stopAllTorrents {
    [self performActionOnTorrents:@"torrent-stop" andEventuallyTorrent:nil];
}

-(void) startAllTorrents {
    [self performActionOnTorrents:@"torrent-start" andEventuallyTorrent:nil];
}



#pragma mark - Remove / Add Torrents


-(void) deleteTorrent:(Torrent *)torrentToDelete deleteData:(BOOL)wantToDelete {
    
    NSNumber *idNumber = [NSNumber numberWithInt:torrentToDelete.torrentId];
   
    if([blockedTorrentIds containsObject:idNumber]) {
        NSLog(@"ACTION ON BLOCKED ELEMENT");
        return;
    
    } else {
        NSString *requestedAction = @"torrent-remove";
        NSMutableDictionary *argumentsForCommand = [[NSMutableDictionary alloc] init];
        NSArray *idArray = [NSArray arrayWithObject:idNumber];
        [argumentsForCommand setObject:idArray forKey:@"ids"];
        if(wantToDelete) {
            NSNumber *yes = [NSNumber numberWithBool:YES];
            [argumentsForCommand setObject:yes forKey:@"delete-local-data"];
        }
        
        [self blockTorrentForCurrentTag:[NSMutableArray arrayWithObject: torrentToDelete]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.dfritsch86.iDifferential.torrentListUpdated" object:self];
        
        [self sendCommandwithMethod:requestedAction andArguments:argumentsForCommand];
    }
}

-(void) deleteTorrentNotData: (Torrent *) torrentToDelete {
    [self deleteTorrent:torrentToDelete deleteData:NO];
}
-(void) deleteTorrentAndData: (Torrent *) torrentToDelete {
    [self deleteTorrent:torrentToDelete deleteData:YES];
}


-(void) addTorrentWithSource: (id) source {
    NSMutableDictionary *argumentsForCommand = [NSMutableDictionary dictionary];
    
    if ([source isKindOfClass:[NSString class]]) {
        [argumentsForCommand setObject:(NSString *)source forKey:@"filename"];
    } else if ([source isKindOfClass:[NSData class]]) {
        NSString *base64String = [Base64Encoding encodeBase64WithData:(NSData *)source];
        [argumentsForCommand setObject:base64String forKey:@"metainfo"];
    }
    [self sendCommandwithMethod:@"torrent-add" andArguments:argumentsForCommand];
}



#pragma mark - RPCClient Delegate 


-(void)clientReturnedresult: (NSDictionary *)result forMethod: (NSString *) method {
    //NSLog(@"RPC Returned Results for method: %@", method);
    //NSLog(@"Results: %@", result);
    
    if ([method isEqualToString:@"torrent-get"] ) {
        
        NSArray *resultArray = [result valueForKeyPath:@"arguments.torrents"];
        [torrentList removeAllObjects];
        upSpeed = 0;
        downSpeed = 0;
        for(NSDictionary *currentTorrent in resultArray) {
            upSpeed += [[currentTorrent objectForKey:@"rateUpload"] integerValue] / 1000.0;
            downSpeed += [[currentTorrent objectForKey:@"rateDownload"] integerValue] / 1000.0;
            
            NSNumber *torrentId = [NSNumber numberWithInt:[[currentTorrent objectForKey:@"id"] integerValue]];
            BOOL isBlocked = ([blockedTorrentIds containsObject:torrentId]) ? YES : NO;
            [torrentList addObject:[[Torrent alloc] initWithDict:currentTorrent andIsBlocked: isBlocked]];
            
        }
        
        [self checkForSomeActivePausedTorrents];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.dfritsch86.iDifferential.torrentListUpdated" object:self];
        //NSLog(@"List: %@", torrentList);
    } 
    
    else if ([method isEqualToString:@"torrent-start"] || [method isEqualToString:@"torrent-stop"] ) {
    
        NSNumber *tag = [NSNumber numberWithInt:[[result valueForKeyPath:@"tag"] integerValue]];
        NSArray *tempArray = [self getTorrentsForTag:tag];
        for(Torrent * currentTorrent in tempArray) {
            if ([method isEqualToString:@"torrent-start"]) {
                currentTorrent.status = currentTorrent.oldStatus;
            } else {
                currentTorrent.oldStatus = currentTorrent.status;
                currentTorrent.status = 0;
            }
        }
        [self removeBlocksForTorrentOfTag:tag];
        [self checkForSomeActivePausedTorrents];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.dfritsch86.iDifferential.torrentListUpdated" object:self];
    }
    
    else if([method isEqualToString:@"torrent-remove"] ) {
        
        NSNumber *tag = [NSNumber numberWithInt:[[result valueForKeyPath:@"tag"] integerValue]];
        NSArray *tempArray = [self getTorrentsForTag:tag];
        for(Torrent * currentTorrent in tempArray) {
            [self.torrentList removeObject:currentTorrent];
        }
        [self removeBlocksForTorrentOfTag:tag];
        [self checkForSomeActivePausedTorrents];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.dfritsch86.iDifferential.torrentListUpdated" object:self];
    }

    else if([method isEqualToString:@"torrent-add"] ) {
        NSString *resultString = [result valueForKey:@"result"];
        if ([resultString isEqualToString:@"duplicate torrent"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The torrent is already being downloaded" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
        else if ([resultString isEqualToString:@"gotMetadataFromURL: http error 0: No Response"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The link to the torrent file doesn't seem to be valid or reachable" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
        else if ([resultString isEqualToString:@"invalid or corrupt torrent file"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The selected torrent file is invalid or corrupted" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
        else if ([resultString isEqualToString:@"success"]) {
            
            NSLog(@"SHOULD MAKE PLACEHOLDER");
            [torrentList addObject:[[Torrent alloc] initWithDict:nil andIsBlocked: YES]];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.dfritsch86.iDifferential.torrentListUpdated" object:self];
        
    }
}



-(void)clientReturnedHttpCode: (int) returnedHttpCode {
    if (returnedHttpCode != 200) {
        
        //checks if the (old) httpcode was 200 (i.e. first error to appear) 
        //if so, fire notification (this is to avoid 1000s of alerts when timeout occurs)
        if ((self.httpCode == 200) && ((returnedHttpCode == 401) || (returnedHttpCode == 0)) ) {
            NSLog(@"TORRENT MANAGER SAYS: connection error");
            self.httpCode = returnedHttpCode;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.dfritsch86.iDifferential.torrentListUpdated" object:self];
        }
    } 
}



#pragma mark - Utilities

-(void) sendCommandwithMethod: (NSString *) method andArguments: (NSMutableDictionary *) argsDict {
    NSMutableDictionary *command = [NSMutableDictionary dictionary];
    [command setObject:method forKey:@"method"];
    [command setObject:argsDict forKey:@"arguments"];
    [command setObject:[NSNumber numberWithInt:currentTag++] forKey:@"tag"];
    [rpcClient performSearchWithData:command forMethod:method];
}



-(NSMutableArray *) trasformResultInTorrentArray: (NSArray *) resultArray {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:1];
    upSpeed = 0;
    downSpeed = 0;
    for(NSDictionary *currentTorrent in resultArray) {
        upSpeed += [[currentTorrent objectForKey:@"rateUpload"] integerValue] / 1000.0;
        downSpeed += [[currentTorrent objectForKey:@"rateDownload"] integerValue] / 1000.0;
        
        NSNumber *torrentId = [NSNumber numberWithInt:[[currentTorrent objectForKey:@"id"] integerValue]];
        BOOL isBlocked = ([blockedTorrentIds containsObject:torrentId]) ? YES : NO;
        NSLog(@"IS BLOCKED: %d", isBlocked);
        [tempArray addObject:[[Torrent alloc] initWithDict:currentTorrent andIsBlocked: isBlocked]];
        
    }
    return tempArray;
}



-(void) checkForSomeActivePausedTorrents {
    
    int numberOfPausedTorrents = 0;
    for(Torrent *currentTorrent in self.torrentList) {
        if (currentTorrent.status == 0) {
            numberOfPausedTorrents++;
        }
    }
    
    if (([self.torrentList count] > 0)) {
        if (numberOfPausedTorrents == [self.torrentList count]) {
            self.someActiveTorrents = NO;
            self.somePausedTorrents = YES;
            //NSLog(@"Is Paused!!");
            
        } else if (numberOfPausedTorrents == 0){
            self.someActiveTorrents = YES;
            self.somePausedTorrents = NO;
            //NSLog(@"Is only active!!");
            
        } else {
            self.someActiveTorrents = YES;
            self.somePausedTorrents = YES;
            //NSLog(@"Is both active and not!!");
        }
    }
}



#pragma mark - Block Manager
/*When user performs action on torrent (pause, start (one or all), remove) the torrent is blocked.
 The block prevents from executing another operation on the same torrent, before the result of the first (blocking) operation
 is returned. This is important, as the rpc protocol does not guarantee the order of execution of operations.
 
 Also, setting a blocked bit is useful when refreshing the torrents view. when a new getbasicinfo arrives, some torrents might still
 be blocked (i.e. awaiting for response of the operation). By checking if they are blocked, consistency of the user information
 can be guaranteed.
 
 The Bloking functions like this:
 
 some operations block torrents
 when this happens, the id(s) of the blocked torrent(s) is stored in an array
 and a tag with the torrents it is blocking is stored in a dict.
 
 When refreshing the view, torrentmanager checks if torrent ids are in the blocked section.
 the dict serves to determine which ids to eventually remove from the array (as the result of the rpc will only containg
 the tag and not the affected ids)
 */


-(void) blockTorrentForCurrentTag: (NSMutableArray *)torrentsToBlock {
   
    for(Torrent *currentTorrent in torrentsToBlock) {
        NSNumber *idNumber = [NSNumber numberWithInt:currentTorrent.torrentId];
        [blockedTorrentIds addObject:idNumber];
        currentTorrent.isBlocked = YES;
    }
    
    [tagBlocksTorrents setObject:[NSArray arrayWithArray:torrentsToBlock] forKey:[NSNumber numberWithInt:currentTag]];
}



-(void) removeBlocksForTorrentOfTag:(NSNumber *) tag {
   
    NSArray *tempTorrentArray = [self getTorrentsForTag:tag];
    //NSLog(@"This tag contains the torrents: %@", tempTorrentArray);
    //NSLog(@"Removing blocks for Tag: %@", tag);
    
    for(Torrent *currentTorrent in tempTorrentArray) {
        NSNumber *idNumber = [NSNumber numberWithInt:currentTorrent.torrentId];
        
        //Can't remove directly, otherwise all instances of idnumeber are gone at once
        int index = [blockedTorrentIds indexOfObject:idNumber];
        [blockedTorrentIds removeObjectAtIndex:index];
        
        //If object is not blocked anymore
        if(![blockedTorrentIds containsObject:idNumber]) {
            currentTorrent.isBlocked = NO;
        }
    }
    
    [tagBlocksTorrents removeObjectForKey:tag];
    
    //NSLog(@"Blocked id list (removed): %@", blockedTorrentIds);
    //NSLog(@"Curernt tag blocking Torrents list (removed): %@", tagBlocksTorrents);
    
}

-(NSArray *) getTorrentsForTag: (NSNumber *) tag {

    return [tagBlocksTorrents objectForKey:tag];
}


#pragma mark - Dealloc Clean

- (void) dealloc
{
    NSLog(@"Torrent Manager dealloc");
    torrentList = nil;
    rpcClient = nil;
}




@end
