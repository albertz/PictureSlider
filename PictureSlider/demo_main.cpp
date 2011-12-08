//
//  demo_main.cpp
//  PictureSlider
//
//  Created by Albert Zeyer on 08.12.11.
//  Copyright (c) 2011 Albert Zeyer. All rights reserved.
//

#include <iostream>
#include <unistd.h>
#include "FileQueue.h"

int main() {
	while(true) {
		std::cout << FileQueue_getNextFile() << std::endl;
		usleep(100*1000);
	}
	return 0;
}
