//
//  ServerSettings.m
//  iDifferential
//
//  Created by Daniel Fritsch on 19/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerSettings.h"

@implementation ServerSettings

@synthesize description, url, port, username, password, refreshRate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.description = [aDecoder decodeObjectForKey:@"Description"];
        self.url = [aDecoder decodeObjectForKey:@"Url"];
        self.port = [aDecoder decodeIntForKey:@"Port"];
        self.username = [aDecoder decodeObjectForKey:@"Username"];
        self.password = [aDecoder decodeObjectForKey:@"Password"];
        self.refreshRate = [aDecoder decodeIntForKey:@"RefreshRate"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.description forKey:@"Description"];
    [aCoder encodeObject:self.url forKey:@"Url"];
    [aCoder encodeInt:self.port forKey:@"Port"];
    [aCoder encodeObject:self.username forKey:@"Username"];
    [aCoder encodeObject:self.password forKey:@"Password"];
    [aCoder encodeInt:self.refreshRate forKey:@"RefreshRate"];
}




@end
