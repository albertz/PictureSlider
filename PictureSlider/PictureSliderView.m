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
    if (currentImageView) [[currentImageView animator] removeFromSuperview];
    if (newImageView) [[self animator] addSubview:newImageView];
	[currentImageView release];
    currentImageView = newImageView;
}


const float slideshowInterval = 5.0;

- (void)startSlideshowTimer {
    if (slideshowTimer == nil && slideshowInterval > 0.0) {
        // Schedule an ordinary NSTimer that will invoke -advanceSlideshow: at regular intervals, each time we need to advance to the next slide.
        slideshowTimer = [[NSTimer scheduledTimerWithTimeInterval:slideshowInterval target:self selector:@selector(advanceSlideshow:) userInfo:nil repeats:YES] retain];
    }
}

- (void)stopSlideshowTimer {
    if (slideshowTimer != nil) {
        // Cancel and release the slideshow advance timer.
        [slideshowTimer invalidate];
        [slideshowTimer release];
        slideshowTimer = nil;
    }
}

- (void)resetSlideshowTimer {
	if(slideshowTimer == nil) return;
	// don't know a better way to do this...
	[self stopSlideshowTimer];
	[self startSlideshowTimer];
}

- (void) queuedFileNamesPop:(NSString**)fn {
	if([queuedFileNames count] > 0) {
		*fn = [queuedFileNames objectAtIndex:0];
		[queuedFileNames removeObjectAtIndex:0];
	}
}

- (NSString*) nextFileName
{
	NSString* fn = nil;
	[self performSelectorOnMainThread:@selector(queuedFileNamesPop:) withObject:(id)&fn waitUntilDone:YES];
	if(!fn) {
		[nextFileNameLock lock];
		fn = [[NSString alloc] initWithUTF8String:FileQueue_getNextFile()];
		[nextFileNameLock unlock];
	}
	return fn;
}

- (void)load:(NSString*)fn {
	NSImage* nextImage = [[NSImage alloc] initWithContentsOfFile:fn];
	NSLog(@"loaded %s", [fn UTF8String]);
	[self performSelectorOnMainThread:@selector(transitionToImage:) withObject:nextImage waitUntilDone:YES];
	[nextImage release];
}

- (void)loadNext {
	NSString* s = [self nextFileName];
	[oldFileNames performSelectorOnMainThread:@selector(addObject:) withObject:s waitUntilDone:YES];
	[self load:s];
}

- (void)advanceSlideshow:(NSTimer *)timer {
	if([queuedFileNames count] > 0) {
		// TODO: print some msg like "press XY to continue with the slideshow"
	}
	else {
		NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadNext) object:nil];
		[thread start];
	}
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/60.0];
    }

	oldFileNames = [[NSMutableArray alloc] init];
	queuedFileNames = [[NSMutableArray alloc] init];
	nextFileNameLock = [[NSLock alloc] init];
	
	[self setWantsLayer:YES];
	[self startSlideshowTimer];
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
    [self stopSlideshowTimer];
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
		case 63234: // left
		{
			if([oldFileNames count] < 2) return;
			NSString* lastFn = [oldFileNames lastObject];
			[oldFileNames removeLastObject];
			[queuedFileNames insertObject:lastFn atIndex:0];
			[self load:[oldFileNames lastObject]];
			break;
		}	
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
	[self resetSlideshowTimer];
}

@end
