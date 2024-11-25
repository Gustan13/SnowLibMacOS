//
//  Node.hpp
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 03/09/24.
//

#ifndef Node_hpp
#define Node_hpp

#include <stdio.h>
#include <Metal/Metal.hpp>

#include "SnowStructs.h"

class Node {
public:
    char name[1024];
    Node* parent;
    Node* children[256];
    int childrenCount;
    
    bool isTransform = false;
    bool isCollider = false;
    bool isPrimitive = false;
    
    Node();
    
    void AddChild(Node* child);
    virtual void Draw( MTL::RenderCommandEncoder* pEnc, Snow_Uniforms* uniforms, Snow_PhongUniforms* phongUniforms, Snow_FStates* allShaders );
    virtual void Update();
};

#endif /* Node_hpp */
