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
	CIImage         *inputShadingImage;         // an environment-map image that the transition filter may use in generating the transition effect
	CIImage         *inputMaskImage;            // a mask image that the transition filter may use in generating the transition effect

	NSTimer* slideshowTimer;
}
@end
