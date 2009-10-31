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
- (void)offsetFrom:(TouchEvent *)event x:(int *)x y:(int *)y;
- (void)offsetFrom:(TouchEvent *)event x1:(int *)x1 y1:(int *)y1 x2:(int *)x2 y2:(int *)y2;
- (void)offsetFrom:(TouchEvent *)event x1:(int *)x1 y1:(int *)y1 x2:(int *)x2 y2:(int *)y2 x3:(int *)x3 y3:(int *)y3;

@end
