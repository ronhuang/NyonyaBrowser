//
//  TouchEvent.m
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TouchEvent.h"


@implementation TouchEvent

@synthesize timestamp, count;

+ (TouchEvent *)touchEventWithRawData:(IRData[4])irData
{
	TouchEvent *event = [[TouchEvent alloc] initWithRawData:irData];
	return [event autorelease];
}

- (id)initWithRawData:(IRData[4])irData
{
	if (self = [super init]) {
		memset(data, 0, sizeof(data));
		count = 0;
		timestamp = [NSDate timeIntervalSinceReferenceDate];
		
		for (int i = 0; i < 4; i++) {
			int s = irData[i].s;
			if (s < 0xF && s > 1) {
				// Ignore small blob
				memcpy(&data[count], &irData[i], sizeof(IRData));
				count++;
			}
		}
	}
	
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"t:%f c:%d\nx1:%d y1:%d s1:%d\nx2:%d y2:%d s2:%d\nx3:%d y3:%d s3:%d\nx4:%d y4:%d s4:%d\n",
			timestamp, count,
			data[0].x, data[0].y, data[0].s,
			data[1].x, data[1].y, data[1].s,
			data[2].x, data[2].y, data[2].s,
			data[3].x, data[3].y, data[3].s];
}

- (IRData)data:(int)index
{
	return data[index];
}

- (void)offsetFrom:(TouchEvent *)event x:(int *)x y:(int *)y
{
	if (!event || !x || !y) {
		return;
	}

	IRData cur = [self data:0];
	IRData pre = [event data:0];

	*x = cur.x - pre.x;
	*y = cur.y - pre.y;
}

@end
