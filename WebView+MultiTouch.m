//
//  WebView+MultiTouch.m
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebView+MultiTouch.h"


@implementation WebView (MultiTouch)

- (void)swipeWithEvent:(NSEvent *)event
{
    CGFloat x = [event deltaX];

	if (x < 0 && [self canGoForward]) {
		[self goForward];
	}
	else if (x > 0 && [self canGoBack]) {
		[self goBack];
	}
}

- (void)magnifyWithEvent:(NSEvent *)event {
	float multiplier = [self textSizeMultiplier] * ([event magnification] + 1.0);
	[self setTextSizeMultiplier:multiplier];
}

@end
