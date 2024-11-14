//
//  SnowSoup.hpp
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 23/08/24.
//

#ifndef SnowSoup_hpp
#define SnowSoup_hpp

//#include <MetalKit/MetalKit.hpp>
#include <MetalKit/MetalKit.h>
#include <Metal/Metal.hpp>
#include <chrono>
#include <thread>

#include <QuartzCore/CAMetalDrawable.hpp>
//#include <ccd/ccd.h>

//#include "MetalView.hpp"
#include "Input.h"
#include "Node.hpp"
#include "Renderer.hpp"
#include "ModelTest.hpp"
#include "Collider.hpp"
#include "CollisionManager.hpp"

class SnowSoup{
public:
    void init(MTKView *view);
    void run();
    
    void addNode(Node* newNode);
    void setView(MTKView *view);
    void setCameraAspect(CGSize size);
    virtual void update();
    virtual void onStart();
    
    MTL::Device* device;
private:
    void initDevice();
    
    Node* sceneTree = nullptr;
    CAMetalLayer* metalLayer;
    
    Renderer* renderer;
    
    std::vector<Collider*>* allColliders = nullptr;
    
    float deltaTime;
    
    MTKView* view = nullptr;
};

#endif /* SnowSoup_hpp */
