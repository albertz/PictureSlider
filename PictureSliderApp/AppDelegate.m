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
	[[self window] setContentView:[[PictureSliderView alloc] init]];
}

- (void) windowWillClose:(NSNotification *)notification
{
	exit(0);
}


@end
