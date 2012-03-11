//
//  RPCClient.m
//  iDifferential
//
//  Created by Daniel Fritsch on 21/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPCClient.h"
#import "AFJSONRequestOperation.h"
#import "Base64Encoding.h"



@implementation RPCClient {
    ServerSettings *server;
    NSString *headerKey;
    NSOperationQueue *queue;
}

@synthesize delegate;


- (id)initWithServer:(ServerSettings *)aServer andDelegate: (id)theDelegate{
    if ((self = [super init])) {
        self->server = aServer;
        self->headerKey = @"Empty";
        self.delegate = theDelegate;
        queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}


-(void) performSearchWithData: (NSMutableDictionary *) data forMethod: (NSString *) method {
    
    NSString *address;
    
    if ([server.password isEqualToString:@""] && [server.username isEqualToString:@""]) {
        address = [NSString stringWithFormat: @"%@:%d/transmission/rpc", server.url, server.port];
    } else {
        address = [NSString stringWithFormat: @"http://%@:%@@%@:%d/transmission/rpc",server.username, server.password, server.url, server.port];
    }
    
    NSURL *url = [NSURL URLWithString: address];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSData *postDataTransmission = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    [request setHTTPBody:postDataTransmission];
    [request setHTTPMethod:@"POST"];
    [request setValue:headerKey forHTTPHeaderField:@"X-Transmission-Session-Id"];
    
   // NSLog(@"RPC CLIENT SAYS: sending request");

    
    AFJSONRequestOperation *operation = 
        [AFJSONRequestOperation
            JSONRequestOperationWithRequest:request
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                
                //NSLog(@"RPC CLIENT SAYS: connection success");

                [self.delegate clientReturnedHttpCode:200];
                [self.delegate clientReturnedresult:JSON forMethod:method];
                
                

            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                            
                NSInteger httpStatus = [(NSHTTPURLResponse*)response statusCode];
                //NSLog(@"Http Status: %i", httpStatus);
                //NSLog(@"Failure! \n%@", error);
                                             
                if (httpStatus == 409) {
                    NSDictionary *headerData = [(NSHTTPURLResponse*)response allHeaderFields];
                    headerKey = [headerData objectForKey:@"X-Transmission-Session-Id"];
                    [self performSearchWithData:data forMethod:method];
                    return;
                                                 
                }
                NSLog(@"RPC CLIENT SAYS: connection error: %d", httpStatus);

                [self.delegate clientReturnedHttpCode:httpStatus];

    }];
    
    operation.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    [queue addOperation:operation];

}



@end
