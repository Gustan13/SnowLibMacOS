//
//  SnowDelegate.cpp
//  SnowLibMacOS
//
//  Created by Gustavo Binder on 11/11/24.
//

#include "SnowDelegate.h"

@interface SnowSoupDelegate ()
@property (nonatomic) SnowSoup* engine;
//@property (nonatomic) MTKView* view;
@end

@implementation SnowSoupDelegate

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {
    _engine->setCameraAspect(size);
}

- (void)drawInMTKView:(MTKView*) view {
    _engine->run();
}

- (void)setEngine:(SnowSoup *)engine {
    _engine = engine;
}

- (void)setView:(NSView*)view {
    MTKView* metalView = (MTKView*)view;
    if (metalView == NULL) {
        printf("View Controller's view is not an MTKView.\n");
        printf("Please change it. :)\n");
        exit(1);
    }
    
    [metalView setDelegate:self];
}

@end
