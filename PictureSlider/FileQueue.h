//
//  FileQueue.h
//  PictureSlider
//
//  Created by Albert Zeyer on 08.12.11.
//  Copyright (c) 2011 Albert Zeyer. All rights reserved.
//

#ifndef PictureSlider_FileQueue_h
#define PictureSlider_FileQueue_h

#ifdef __cplusplus
extern "C" {
#endif
	
	const char* FileQueue_getNextFile();
	void FileQueue_reset();
	
#ifdef __cplusplus
}
#endif

#endif
