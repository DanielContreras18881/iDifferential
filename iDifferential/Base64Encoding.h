//
//  Base64Encoding.h
//  iDifferential2
//
//  Created by Daniel Fritsch on 23/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64Encoding : NSObject

+ (NSString *)encodeBase64WithString:(NSString *)strData;
+ (NSString *)encodeBase64WithData:(NSData *)objData;

@end
