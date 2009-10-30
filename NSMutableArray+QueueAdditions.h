//
//  NSMutableArray+QueueAdditions.h
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end
