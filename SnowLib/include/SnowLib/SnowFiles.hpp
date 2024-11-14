//
//  SnowFiles.hpp
//  SnowLibMacOS
//
//  Created by Gustavo Binder on 11/11/24.
//

#ifndef SnowFiles_hpp
#define SnowFiles_hpp

#import <Cocoa/Cocoa.h>
#include <stdio.h>

class SnowFiles {
public:
    static const char* getPath(NSString* filename, NSString* extension);
protected:
    static NSBundle* main;
};

#endif /* SnowFiles_hpp */
