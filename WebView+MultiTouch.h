//
//  WebView+MultiTouch.h
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface WebView (MultiTouch)

- (void)swipeWithEvent:(NSEvent *)event;

@end
