//
//  AppDelegate.m
//  PictureSliderApp
//
//  Created by Albert Zeyer on 09.12.11.
//  Copyright (c) 2011 Albert Zeyer. All rights reserved.
//

#import "AppDelegate.h"
#import "PictureSliderView.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	NSLog(@"applicationDidFinishLaunching");
	NSView* view = [[PictureSliderView alloc] init];
	[[self window] setContentView:view];
	[[self window] makeFirstResponder:view];
}

- (void) windowWillClose:(NSNotification *)notification
{
	exit(0);
}


@end
