//
//  PictureSliderView.h
//  PictureSlider
//
//  Created by Albert Zeyer on 08.12.11.
//  Copyright (c) 2011 Albert Zeyer. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CoreImage.h>

@interface PictureSliderView : ScreenSaverView
{
	NSImageView     *currentImageView;          // an NSImageView that displays the current image, as a subview of the SlideshowView

	NSTimer* slideshowTimer;
	
	NSLock* nextFileNameLock;
}
@end
