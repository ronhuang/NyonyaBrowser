//
//  MyDocument.h
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WiiRemote/WiiRemote.h>
#import <WiiRemote/WiiRemoteDiscovery.h>
#import <Quartz/Quartz.h>
#import "TouchEvent.h"

@interface MyDocument : NSDocument
{
	IBOutlet WebView *webView;
	IBOutlet NSTextField *textField;
	IBOutlet NSButton *backButton;
	IBOutlet NSButton *forwardButton;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSProgressIndicator *discoverySpinner;
	IBOutlet NSButton *findWiimoteButton;
	IBOutlet QCView *irQCView;

	int resourceCount;
	int resourceFailedCount;
	int resourceCompletedCount;

	WiiRemoteDiscovery *discovery;
	WiiRemote *wii;

	NSMutableArray *touchQueue;

	int dispWidth;
	int dispHeight;
}

- (IBAction) connectURL:(id)sender;
- (IBAction) doDiscovery:(id)sender;

@end
