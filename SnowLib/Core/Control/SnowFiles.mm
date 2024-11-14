//
//  SnowFiles.cpp
//  SnowLibMacOS
//
//  Created by Gustavo Binder on 11/11/24.
//

#include "SnowFiles.hpp"

const char* SnowFiles::getPath(NSString* filename, NSString* extension) {
    if (main == nullptr) {
        main = [NSBundle mainBundle];
        assert(main != nullptr);
    }
    
    NSString* path = [main pathForResource: filename ofType: extension];
    
    assert(path != nullptr);
    return [path UTF8String];
}

NSBundle* SnowFiles::main = nullptr;
