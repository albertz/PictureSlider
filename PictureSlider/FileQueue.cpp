//
//  FileQueue.cpp
//  PictureSlider
//
//  Created by Albert Zeyer on 08.12.11.
//  Copyright (c) 2011 Albert Zeyer. All rights reserved.
//

#include "FileQueue.h"
#include <deque>
#include <string>
#include <memory>
#include <list>
#include <random>
#include <iostream>
#include <assert.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>

std::mt19937 rnd((uint32_t)time(NULL));

static uint64_t rndInt(uint64_t min, uint64_t max) {
	return std::uniform_int_distribution<uint64_t>(min,max)(rnd);
}

static bool _isGoodFile(const std::string& basefn, struct dirent* dp) {
	auto l = dp->d_namlen;
	if(l <= 4) return false;
	if(dp->d_name[l-4] == '.' &&
	   (dp->d_name[l-3] == 'j' || dp->d_name[l-3] == 'J') &&
	   (dp->d_name[l-2] == 'p' || dp->d_name[l-2] == 'P') &&
	   (dp->d_name[l-1] == 'g' || dp->d_name[l-1] == 'G')) {
		std::string fn = basefn + "/" + dp->d_name;
		struct stat s;
		if(stat(fn.c_str(), &s) != 0) return false;
		if(s.st_size < 1*1024*1024) return false; // pictures of size <1MB are too small
		return true;
	}
	return false;
}

static const float C_nonloaded_dirs_expectedFac = 0.5;

struct Dir {
	Dir(): isLoaded(false) {}
	std::string base;
	bool isLoaded;
	std::deque<std::string> files;
	std::deque<std::shared_ptr<Dir> > loadedDirs;
	std::deque<std::shared_ptr<Dir> > nonloadedDirs;
		
	void load() {
		isLoaded = true;
		DIR* d = opendir(base.c_str());
		if(d == NULL) {
			fprintf(stderr, "warning: cannot read dir `%s`\n", base.c_str());
			return;
		}
		while(true) {
			struct dirent* dp = readdir(d);
			if(dp == NULL) break;
			if(dp->d_name[0] == '.') continue;
			if(strcmp(dp->d_name, "iPhoto Library") == 0) continue;
			if(strcmp(dp->d_name, "iPod Photo Cache") == 0) continue;
			if(strcmp(dp->d_name, "Photo Booth") == 0) continue;
			if(dp->d_type == DT_REG) {
				if(_isGoodFile(base, dp))
					files.push_back(dp->d_name);
			} else if(dp->d_type == DT_DIR) {
				std::shared_ptr<Dir> subdir(new Dir);
				subdir->base = base + "/" + dp->d_name;
				nonloadedDirs.push_back(subdir);
			}
		}
		closedir(d);
	}
	
	size_t expectedFilesCount() {
		size_t c = 0;
		c += files.size();
		for(auto& d : loadedDirs)
			c += d->expectedFilesCount();
		c += size_t( nonloadedDirs.size() * C_nonloaded_dirs_expectedFac * c );
		return c;
	}
	
	std::string randomGet() {
		if(!isLoaded) load();
		
		while(true) {
			size_t rmax = expectedFilesCount();
			if(rmax == 0) return "";
			size_t r = rndInt(0, rmax - 1);
			//printf("randomGet(%s): files:%lu, exp:%lu, rnd:%lu\n", base.c_str(), files.size(), rmax, r);
			
			if(r < files.size())
				return base + "/" + files[r];
			r -= files.size();
			
			for(auto& d : loadedDirs) {
				size_t c = d->expectedFilesCount();
				if(r < c)
					return d->randomGet();
				r -= c;
			}
			
			assert(nonloadedDirs.size() > 0);
			r = rndInt(0, nonloadedDirs.size() - 1);
			std::shared_ptr<Dir> d = nonloadedDirs[r];
			nonloadedDirs.erase(nonloadedDirs.begin() + r);
			d->load();
			loadedDirs.push_back(d);
		}
	}
};

struct FileQueue {
	Dir root;
	FileQueue() {
		std::string homeDir = getenv("HOME");
		root.base = homeDir + "/Pictures";
	}
};

FileQueue _queue;

static std::string _nextFile;

const char* FileQueue_getNextFile() {
	_nextFile = _queue.root.randomGet();
	return _nextFile.c_str();
}

