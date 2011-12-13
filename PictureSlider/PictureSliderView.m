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

// Much of the code for the transition animation is based on Apples Cocoa Slides example.

@implementation PictureSliderView

- (void)transitionToImage:(NSImage *)newImage {
    NSImageView *newImageView = nil;
    if (newImage) {
        newImageView = [[NSImageView alloc] initWithFrame:[self bounds]];
        [newImageView setImage:newImage];
        [newImageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    if (currentImageView) [currentImageView removeFromSuperview];
    if (newImageView) [self addSubview:newImageView];
	[currentImageView release];
    currentImageView = newImageView;
}


- (NSString*) nextFileName
{
	NSString* fn = nil;
	[nextFileNameLock lock];
	fn = [[NSString alloc] initWithUTF8String:FileQueue_getNextFile()];
	[nextFileNameLock unlock];
	return fn;
}

- (void)load:(NSString*)fn {
	NSImage* nextImage = [[NSImage alloc] initWithContentsOfFile:fn];
	NSLog(@"loaded %s", [fn UTF8String]);
	[self performSelectorOnMainThread:@selector(transitionToImage:) withObject:nextImage waitUntilDone:YES];
	[nextImage release];
	[fn release];
}

- (void)loadNext {
	NSString* s = [self nextFileName];
	[self load:s];
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/60.0];
    }

	nextFileNameLock = [[NSLock alloc] init];
	
	[self setWantsLayer:YES];
	[self loadNext];

	return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
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

- (void)dealloc {
    [currentImageView release];
    [super dealloc];
}

- (BOOL)isOpaque {
    // We're opaque, since we fill with solid black in our -drawRect: method, below.
    return YES;
}

- (void)drawRect:(NSRect)rect {
    // Draw a solid black background.
    [[NSColor blackColor] set];
    NSRectFill(rect);
}

- (void)keyDown:(NSEvent *)theEvent
{
	unichar c = [[theEvent characters] characterAtIndex:0];
	switch(c) {
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

@end
