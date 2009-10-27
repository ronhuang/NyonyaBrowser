//
//  MyDocument.h
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MyDocument : NSDocument
{
	IBOutlet WebView* webView;
	IBOutlet NSTextField* textField;
	IBOutlet NSButton* backButton;
	IBOutlet NSButton* forwardButton;
	IBOutlet NSProgressIndicator* progress;
	
	int resourceCount;
	int resourceFailedCount;
	int resourceCompletedCount;
}

- (IBAction) connectURL:(id)sender;

@end
