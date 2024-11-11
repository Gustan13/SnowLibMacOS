//
//  ModelTest.hpp
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 06/09/24.
//

#ifndef ModelTest_hpp
#define ModelTest_hpp

#include <Metal/Metal.hpp>

#include "Model.hpp"
#include "Input.h"

class ModelTest : public Model {
public:
    ModelTest(MTL::Device* device);
    
    bool ctrlHead = true;
    
    Input* input;
    MeshNode* myHead = nullptr, *myHair = nullptr;
    void Update() override;
};


#endif /* ModelTest_hpp */
