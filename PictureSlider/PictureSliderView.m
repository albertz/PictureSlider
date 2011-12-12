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

typedef enum {
    // Core Animation's four built-in transition types
    SlideshowViewFadeTransitionStyle,
    SlideshowViewMoveInTransitionStyle,
    SlideshowViewPushTransitionStyle,
    SlideshowViewRevealTransitionStyle,
	
    // Core Image's standard set of transition filters
    SlideshowViewCopyMachineTransitionStyle,
    SlideshowViewDisintegrateWithMaskTransitionStyle,
    SlideshowViewDissolveTransitionStyle,
    SlideshowViewFlashTransitionStyle,
    SlideshowViewModTransitionStyle,
    SlideshowViewPageCurlTransitionStyle,
    SlideshowViewRippleTransitionStyle,
    SlideshowViewSwipeTransitionStyle,
	
    NumberOfSlideshowViewTransitionStyles
} SlideshowViewTransitionStyle;

const SlideshowViewTransitionStyle transitionStyle = SlideshowViewFadeTransitionStyle;


- (void)updateSubviewsTransition {
    NSRect rect = [self bounds];
    NSString *transitionType = nil;
    CIFilter *transitionFilter = nil;
    CIFilter *maskScalingFilter = nil;
    CGRect maskExtent;
	
    // Map our transitionStyle to one of Core Animation's four built-in CATransition types, or an appropriately instantiated and configured Core Image CIFilter.  (The code used to construct the CIFilters here is very similar to that in the "Reducer" code sample from WWDC 2005.  See http://developer.apple.com/samplecode/Reducer/ )
    switch (transitionStyle) {
        case SlideshowViewFadeTransitionStyle:
            transitionType = kCATransitionFade;
            break;
			
        case SlideshowViewMoveInTransitionStyle:
            transitionType = kCATransitionMoveIn;
            break;
			
        case SlideshowViewPushTransitionStyle:
            transitionType = kCATransitionPush;
            break;
			
        case SlideshowViewRevealTransitionStyle:
            transitionType = kCATransitionReveal;
            break;
			
        case SlideshowViewCopyMachineTransitionStyle:
            transitionFilter = [[CIFilter filterWithName:@"CICopyMachineTransition"] retain];
            [transitionFilter setDefaults];
            [transitionFilter setValue:[CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height] forKey:@"inputExtent"];
            break;
			
        case SlideshowViewDisintegrateWithMaskTransitionStyle:
            transitionFilter = [[CIFilter filterWithName:@"CIDisintegrateWithMaskTransition"] retain];
            [transitionFilter setDefaults];
			
            // Scale our mask image to match the transition area size, and set the scaled result as the "inputMaskImage" to the transitionFilter.
            maskScalingFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
            [maskScalingFilter setDefaults];
            maskExtent = [inputMaskImage extent];
            float xScale = rect.size.width / maskExtent.size.width;
            float yScale = rect.size.height / maskExtent.size.height;
            [maskScalingFilter setValue:[NSNumber numberWithFloat:yScale] forKey:@"inputScale"];
            [maskScalingFilter setValue:[NSNumber numberWithFloat:xScale / yScale] forKey:@"inputAspectRatio"];
            [maskScalingFilter setValue:inputMaskImage forKey:@"inputImage"];
			
            [transitionFilter setValue:[maskScalingFilter valueForKey:@"outputImage"] forKey:@"inputMaskImage"];
            break;
			
        case SlideshowViewDissolveTransitionStyle:
            transitionFilter = [[CIFilter filterWithName:@"CIDissolveTransition"] retain];
            [transitionFilter setDefaults];
            break;
			
        case SlideshowViewFlashTransitionStyle:
            transitionFilter = [[CIFilter filterWithName:@"CIFlashTransition"] retain];
            [transitionFilter setDefaults];
            [transitionFilter setValue:[CIVector vectorWithX:NSMidX(rect) Y:NSMidY(rect)] forKey:@"inputCenter"];
            [transitionFilter setValue:[CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height] forKey:@"inputExtent"];
            break;
			
        case SlideshowViewModTransitionStyle:
            transitionFilter = [[CIFilter filterWithName:@"CIModTransition"] retain];
            [transitionFilter setDefaults];
            [transitionFilter setValue:[CIVector vectorWithX:NSMidX(rect) Y:NSMidY(rect)] forKey:@"inputCenter"];
            break;
			
        case SlideshowViewPageCurlTransitionStyle:
            transitionFilter = [[CIFilter filterWithName:@"CIPageCurlTransition"] retain];
            [transitionFilter setDefaults];
            [transitionFilter setValue:[NSNumber numberWithFloat:-M_PI_4] forKey:@"inputAngle"];
            [transitionFilter setValue:inputShadingImage forKey:@"inputShadingImage"];
            [transitionFilter setValue:inputShadingImage forKey:@"inputBacksideImage"];
            [transitionFilter setValue:[CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height] forKey:@"inputExtent"];
            break;
			
        case SlideshowViewSwipeTransitionStyle:
            transitionFilter = [[CIFilter filterWithName:@"CISwipeTransition"] retain];
            [transitionFilter setDefaults];
            break;
			
        case SlideshowViewRippleTransitionStyle:
        default:
            transitionFilter = [[CIFilter filterWithName:@"CIRippleTransition"] retain];
            [transitionFilter setDefaults];
            [transitionFilter setValue:[CIVector vectorWithX:NSMidX(rect) Y:NSMidY(rect)] forKey:@"inputCenter"];
            [transitionFilter setValue:[CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height] forKey:@"inputExtent"];
            [transitionFilter setValue:inputShadingImage forKey:@"inputShadingImage"];
            break;
    }
	
    // Construct a new CATransition that describes the transition effect we want.
    CATransition *transition = [CATransition animation];
    if (transitionFilter) {
        // We want to build a CIFilter-based CATransition.  When an CATransition's "filter" property is set, the CATransition's "type" and "subtype" properties are ignored, so we don't need to bother setting them.
        [transition setFilter:transitionFilter];
    } else {
        // We want to specify one of Core Animation's built-in transitions.
        [transition setType:transitionType];
        [transition setSubtype:kCATransitionFromLeft];
    }
	
    // Specify an explicit duration for the transition.
    [transition setDuration:1.0];
	
    // Associate the CATransition we've just built with the "subviews" key for this SlideshowView instance, so that when we swap ImageView instances in our -transitionToImage: method below (via -replaceSubview:with:).
    [self setAnimations:[NSDictionary dictionaryWithObject:transition forKey:@"subviews"]];
}

- initWithFrame:(NSRect)newFrame {
    self = [super initWithFrame:newFrame];
    if (self) {
        [self updateSubviewsTransition];
    }
    return self;
}


- (void)transitionToImage:(NSImage *)newImage {
    // Create a new NSImageView and swap it into the view in place of our previous NSImageView.  This will trigger the transition animation we've wired up in -updateSubviewsTransition, which fires on changes in the "subviews" property.
    NSImageView *newImageView = nil;
    if (newImage) {
        newImageView = [[NSImageView alloc] initWithFrame:[self bounds]];
        [newImageView setImage:newImage];
        [newImageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    if (currentImageView && newImageView) {
        [[self animator] replaceSubview:currentImageView with:newImageView];
    } else {
        if (currentImageView) [[currentImageView animator] removeFromSuperview];
        if (newImageView) [[self animator] addSubview:newImageView];
    }
	[currentImageView release];
    currentImageView = newImageView;
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
	
    // Some Core Image transition filters have geometric parameters that we derive from the view's dimensions.  So when the view is resized, we may need to update our "subviews" CATransition to match its new dimensions.
    switch (transitionStyle) {
        case SlideshowViewCopyMachineTransitionStyle:
        case SlideshowViewDisintegrateWithMaskTransitionStyle:
        case SlideshowViewFlashTransitionStyle:
        case SlideshowViewModTransitionStyle:
        case SlideshowViewPageCurlTransitionStyle:
        case SlideshowViewRippleTransitionStyle:
            [self updateSubviewsTransition];
            break;
		default: break;
    }
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
	//NSLog(@"keydown: %hu", [[theEvent characters] characterAtIndex:0]);
	switch(c) {
		case 63234: // left
		{
			NSLog(@"left, olds: %@", oldFileNames);
			if([oldFileNames count] < 2) return;
			NSString* lastFn = [oldFileNames lastObject];
			NSLog(@"last: %@", lastFn);
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
			[super keyDown:theEvent];
			break;
	}
	[self resetSlideshowTimer];
}

@end
