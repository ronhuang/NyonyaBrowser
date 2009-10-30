//
//  MyDocument.m
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "TouchEvent.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (void) dealloc
{
	[wii release];
	[discovery release];
	[super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	[webView setUIDelegate:self];
	[webView setFrameLoadDelegate:self];
	[webView setResourceLoadDelegate:self];
	[webView setGroupName:@"MyDocument"];
	
	NSString *urlText = [NSString stringWithString:@"http://www.google.com"];
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlText]]];
	
	// Wiimote
	discovery = [[WiiRemoteDiscovery alloc] init];
	[discovery setDelegate:self];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

#pragma mark -
#pragma mark Actions

- (IBAction) connectURL:(id)sender
{
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[sender stringValue]]]];
}

- (IBAction)doDiscovery:(id)sender
{
	[discovery start];

	[progress startAnimation:self];
	[findWiimoteButton setEnabled:NO];
}

#pragma mark -
#pragma mark Methods

- (void)updateResourceStatus
{
	//NSLog(@"t:%d,f:%d,c:%d", resourceCount, resourceFailedCount, resourceCompletedCount);
	if (resourceCount > (resourceFailedCount + resourceCompletedCount)) {
		[progress startAnimation:self];
	}
	else {
		[progress stopAnimation:self];
	}

}

- (void)enableIR
{
	[wii setIRSensorEnabled:YES];
}

- (void)updateIRView:(TouchEvent *)event
{
	for (int i = 0; i < event.count; i++) {
		IRData data = [event data:i];
		float scaledX = ((data.x / 1024.0) * 2.0) - 1.0;
		float scaledY = ((data.y / 768.0) * 1.5) - 0.75;
		float scaledSize = data.s / 16.0;
		int pos = i + 1;

		[irQCView setValue:[NSNumber numberWithFloat: scaledX] forInputKey:[NSString stringWithFormat:@"Point%dX", pos]];
		[irQCView setValue:[NSNumber numberWithFloat: scaledY] forInputKey:[NSString stringWithFormat:@"Point%dY", pos]];
		[irQCView setValue:[NSNumber numberWithFloat: scaledSize] forInputKey:[NSString stringWithFormat:@"Point%dSize", pos]];

		[irQCView setValue:[NSNumber numberWithBool: YES] forInputKey:[NSString stringWithFormat:@"Point%dEnable", pos]];
	}
	for (int i = event.count; i < 4; i++) {
		[irQCView setValue:[NSNumber numberWithBool: NO] forInputKey:[NSString stringWithFormat:@"Point%dEnable", i + 1]];		
	}
}

#pragma mark -
#pragma mark WebView delegates

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    id myDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType:@"DocumentType" display:YES];
    [[[myDocument webView] mainFrame] loadRequest:request];
    return [myDocument webView];
}

- (void)webViewShow:(WebView *)sender
{
    id myDocument = [[NSDocumentController sharedDocumentController] documentForWindow:[sender window]];
    [myDocument showWindows];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        [textField setStringValue:url];
		
		resourceCount = 0;
		resourceFailedCount = 0;
		resourceCompletedCount = 0;
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    // Report feedback only for the main frame.
    if (frame == [sender mainFrame]){
        [[sender window] setTitle:title];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
		[backButton setEnabled:[sender canGoBack]];
		[forwardButton setEnabled:[sender canGoForward]];
    }
}

- (id)webView:(WebView *)sender
identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
    // Return some object that can be used to identify this resource
    return [NSNumber numberWithInt:resourceCount++];
}

-(NSURLRequest *)webView:(WebView *)sender
resource:(id)identifier
willSendRequest:(NSURLRequest *)request
redirectResponse:(NSURLResponse *)redirectResponse
fromDataSource:(WebDataSource *)dataSource
{
    // Update the status message
    [self updateResourceStatus];
    return request;
}

-(void)webView:(WebView *)sender resource:(id)identifier
didFailLoadingWithError:(NSError *)error
fromDataSource:(WebDataSource *)dataSource
{
    resourceFailedCount++;
    // Update the status message
    [self updateResourceStatus];
}

-(void)webView:(WebView *)sender
resource:(id)identifier
didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    resourceCompletedCount++;
    // Update the status message
    [self updateResourceStatus];
}

#pragma mark -
#pragma mark Wiimote delegates

- (void) wiiRemoteDisconnected:(IOBluetoothDevice*)device
{
	[wii release];
	wii = nil;
	
	[findWiimoteButton setHidden:NO];
	[irQCView setHidden:YES];	
}

- (void) rawIRData:(IRData[4])irData
{
	// Wrap raw data to TouchEvent.
	TouchEvent* event = [TouchEvent touchEventWithRawData:irData];

	//NSLog(@"%@", event);

	if (1 == event.count) {
		// Point, click, double click
	} else if (2 == event.count) {
		// Scroll, zoom
	} else if (3 == event.count) {
		// Swipt
	}

	[self updateIRView:event];
}

- (void) accelerationChanged:(WiiAccelerationSensorType)type accX:(unsigned short)accX accY:(unsigned short)accY accZ:(unsigned short)accZ
{
	// Do nothing.
	// This is here because WiiRemoteFramework invoke this without asking if this delegate exist or not.
}

- (void) buttonChanged:(WiiButtonType)type isPressed:(BOOL)isPressed
{
	// Do nothing.
	// This is here because WiiRemoteFramework invoke this without asking if this delegate exist or not.
}

#pragma mark -
#pragma mark WiiRemoteDiscovery delegates

- (void) WiiRemoteDiscoveryError:(int)code
{
	[progress stopAnimation:self];
	[findWiimoteButton setEnabled:YES];
}

- (void) willStartWiimoteConnections
{
}

- (void) WiiRemoteDiscovered:(WiiRemote*)wiimote
{
	//	[discovery stop];
	
	// the wiimote must be retained because the discovery provides us with an autoreleased object
	wii = [wiimote retain];
	[wii setDelegate:self];
	
	[progress stopAnimation:self];
	[findWiimoteButton setEnabled:YES];
	[findWiimoteButton setHidden:YES];
	[irQCView setHidden:NO];
	
	[wii setLEDEnabled1:YES enabled2:NO enabled3:NO enabled4:NO];
	
	//[wii setIRSensorEnabled:YES];
	[self performSelector:@selector(enableIR) withObject:nil afterDelay:1];
}

@end
