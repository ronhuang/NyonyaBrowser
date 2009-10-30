//
//  MyDocument.m
//  NyonyaBrowser
//
//  Created by Ron Huang on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "NSMutableArray+QueueAdditions.h"

// Monitor click event for this many milliseconds
#define kClickMonitorInterval 500
// Touch event comes roughly every 10ms.
#define kTouchEventInterval 10
// Touch event queue size
#define kTouchQueueSize (kClickMonitorInterval / kTouchEventInterval)

#pragma mark -
#pragma mark Function

void postMouseEvent(CGMouseButton button, CGEventType type, const CGPoint point) 
{
	CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, point, button);
	CGEventSetType(theEvent, type);
	CGEventPost(kCGHIDEventTap, theEvent);
	CFRelease(theEvent);
}

void leftClick(const CGPoint point)
{
	postMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseDown, point);
	postMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseUp, point);
}

void rightClick(const CGPoint point)
{
	postMouseEvent(kCGMouseButtonRight, kCGEventRightMouseDown, point);
	postMouseEvent(kCGMouseButtonRight, kCGEventRightMouseUp, point);
}

void doubleClick(const CGPoint point)
{
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, point, kCGMouseButtonLeft);  
    CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 2);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseDown);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

#pragma mark -

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
	[touchQueue release];
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

	touchQueue = [[NSMutableArray arrayWithCapacity:kTouchQueueSize] retain];
	monitoringClick = NO;

	dispWidth = CGDisplayPixelsWide(kCGDirectMainDisplay);
	dispHeight = CGDisplayPixelsHigh(kCGDirectMainDisplay);
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
#pragma mark Private methods

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

- (void)clickTimeout
{
	NSMutableString *identity = [NSMutableString string];
	__block int previousCount = -1;

	[touchQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		TouchEvent *event = (TouchEvent *)obj;
		int count = [event count];

		if (-1 == previousCount) {
			[identity appendFormat:@"%d", count];
		} else if (count != previousCount) {
			[identity appendFormat:@"%d", count];
		}

		previousCount = count;
	}];

	if (NSOrderedSame == [identity compare:@"010"]) {
		// Click
		NSPoint cur = [NSEvent mouseLocation];
		leftClick(CGPointMake(cur.x, dispHeight - cur.y + 1));
	} else if (NSOrderedSame == [identity compare:@"01010"]) {
		// Double click
		NSPoint cur = [NSEvent mouseLocation];
		doubleClick(CGPointMake(cur.x, dispHeight - cur.y + 1));
	} else if (NSOrderedSame == [identity compare:@"020"]) {
		// Right click
		NSPoint cur = [NSEvent mouseLocation];
		rightClick(CGPointMake(cur.x, dispHeight - cur.y + 1));
	}
	monitoringClick = NO;
}

- (void)handleNoTouch
{
	TouchEvent *previousEvent = nil;

	if ([touchQueue count] > 0) {
		previousEvent = (TouchEvent *)[touchQueue objectAtIndex:[touchQueue count] - 1];
	}
	if (!previousEvent || 0 == previousEvent.count) {
		// No previous event. Do nothing.
		return;
	}

	[touchQueue removeAllObjects];
	[self performSelector:@selector(clickTimeout) withObject:nil afterDelay:(NSTimeInterval)((double)kClickMonitorInterval / 1000)];
	monitoringClick = YES;
}

- (void)handleSingleTouch:(TouchEvent *)event
{
	TouchEvent *previousEvent = nil;

	if ([touchQueue count] > 0) {
		previousEvent = (TouchEvent *)[touchQueue objectAtIndex:[touchQueue count] - 1];
	}
	if (!previousEvent) {
		// No previous event. Do nothing.
		return;
	}
	if (1 != previousEvent.count) {
		// Start new leaf.
		return;
	}

	int ox = 0, oy = 0;
	[event offsetFrom:previousEvent x:&ox y:&oy];
	NSLog(@"ox:%d oy:%d", ox, oy);

	if (abs(ox) < 2 && abs(oy) < 2) {
		// Ignore jitters.
		return;
	}

	// Calculate next cursor position.
	// TODO: acceleration
	NSPoint next = [NSEvent mouseLocation];
	next.x += (CGFloat)ox;
	if (next.x < 1) next.x = 1;
	if (next.x > (CGFloat)dispWidth) next.x = (CGFloat)dispWidth;
	next.y = dispHeight - next.y + 1 - (CGFloat)oy;
	if (next.y < 1) next.y = 1;
	if (next.y > (CGFloat)dispHeight) next.y = (CGFloat)dispHeight;

	// Move cursor
	postMouseEvent(kCGMouseButtonLeft, kCGEventMouseMoved, CGPointMake(next.x, next.y));
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

	// Check if the click timer exist.
	// TODO: If exist, check if the current touch is too far from the previous touch
	if (!monitoringClick) {
		if (0 == event.count) {
			[self handleNoTouch];
		} else if (1 == event.count) {
			[self handleSingleTouch:event];
		} else if (2 == event.count) {
		} else if (3 == event.count) {
		}
	}

	// Keep previous event.
	if ([touchQueue count] >= kTouchQueueSize)
		[touchQueue dequeue];
	[touchQueue enqueue:event];

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
