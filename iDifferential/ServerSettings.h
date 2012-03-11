//
//  ServerSettings.h
//  iDifferential
//
//  Created by Daniel Fritsch on 19/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerSettings : NSObject <NSCoding>

@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *url;
@property (nonatomic) NSInteger port;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic) NSInteger refreshRate;

@end
