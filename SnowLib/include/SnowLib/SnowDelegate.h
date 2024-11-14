//
//  SnowDelegate.h
//  SnowLibMacOS
//
//  Created by Gustavo Binder on 11/11/24.
//

#ifndef SnowDelegate_h
#define SnowDelegate_h

#import <MetalKit/MetalKit.h>
#import "SnowSoup.hpp"

@interface SnowSoupDelegate : NSObject <MTKViewDelegate>
- (void)setEngine:(SnowSoup *)engine;
- (void)setView:(NSView*)view;
@end

#endif /* SnowDelegate_h */
