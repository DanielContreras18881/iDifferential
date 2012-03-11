//
//  DataModel.h
//  iDifferential
//
//  Created by Daniel Fritsch on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic, strong) NSMutableArray *serverList;

- (void)saveServerList;
- (int)indexOfSelectedServer;
- (void)setIndexOfSelectedServer:(int)index;


@end
