//
//  TouchEvent.h
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WiiRemote/WiiRemote.h>


@interface TouchEvent : NSObject {
	IRData data[4];
	int count;
	NSTimeInterval timestamp;
}

@property(readonly) NSTimeInterval timestamp;
@property(readonly) int count;

+ (TouchEvent *)touchEventWithRawData:(IRData[4])irData;
- (id)initWithRawData:(IRData[4])irData;
- (IRData)data:(int)index;

@end
