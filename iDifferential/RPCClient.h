//
//  RPCClient.h
//  iDifferential
//
//  Created by Daniel Fritsch on 21/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerSettings.h"

@protocol RPCClientDelegate <NSObject>
-(void)clientReturnedresult: (NSDictionary *)result forMethod: (NSString *) method;
-(void)clientReturnedHttpCode: (int) errorCode;
@end

@interface RPCClient : NSObject

@property (weak, nonatomic) id<RPCClientDelegate> delegate;

-(id)initWithServer: (ServerSettings *)givenServer andDelegate:(id) delegate;
-(void) performSearchWithData: (NSMutableDictionary *) data forMethod: (NSString *) method;


@end
