//
//  SnowMaterial.hpp
//  SnowLibMacOS
//
//  Created by Gustavo Binder on 12/11/24.
//

#ifndef SnowMaterial_hpp
#define SnowMaterial_hpp

#include <simd/simd.h>
#include "Texture.hpp"

class SnowMaterial {
public:
    Texture* texture = nullptr;
    simd_float4 color = simd_make_float4(0.f,0.f,0.f,1.f);
};

#endif /* SnowMaterial_hpp */
