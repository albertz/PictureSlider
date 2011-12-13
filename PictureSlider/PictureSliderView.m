//
//  PictureSliderView.m
//  PictureSlider
//
//  Created by Albert Zeyer on 08.12.11.
//  Copyright (c) 2011 Albert Zeyer. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CoreImage.h>
#include <stdio.h>
#import "PictureSliderView.h"
#include "FileQueue.h"

@implementation PictureSliderView

- (NSString*)nextFileName
{
	NSString* fn = [[NSString alloc] initWithUTF8String:FileQueue_getNextFile()];
	FileQueue_reset(); // just to ensure that there is no memory taken by this
	return fn;
}

- (void)loadNext {
	NSString* fn = [self nextFileName];
	NSImage* nextImage = [[NSImage alloc] initWithContentsOfFile:fn];
	NSLog(@"loaded %s", [fn UTF8String]);
	[nextImage release];
}

- (void)keyDown:(NSEvent *)theEvent
{
	unichar c = [[theEvent characters] characterAtIndex:0];
	switch(c) {
		case 's':
			while(true) {
				[self loadNext];
			}
			break;
		case 63235: // right
			[self loadNext];
			break;
		case 27: // esc
			exit(0);
		default:
			NSLog(@"unhandled keydown: %hu", [[theEvent characters] characterAtIndex:0]);
			[super keyDown:theEvent];
			break;
	}
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/60.0];
    }
	
	[self setWantsLayer:YES];
	[self loadNext];

	return self;
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (BOOL)isOpaque {
    return YES;
}


@end
