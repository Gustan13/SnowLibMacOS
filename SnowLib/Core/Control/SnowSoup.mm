//
//  SnowSoup.mm
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 23/08/24.
//

#include "SnowSoup.hpp"

void SnowSoup::init(MTKView *view) {
    CollisionManager* initCM = CollisionManager::getInstance();
    Input* inputen = Input::getInstance();
    
    sceneTree = new Node;
    
    initDevice();
    
    Cube* cube = new Cube(device);
    cube->setColor(0.f, 1.f, 0.f);
    cube->buildBuffers();
    
    allColliders = new std::vector<Collider*>();
    renderer = new Renderer(device, allColliders, view);
    this->view = view;
    
    setCameraAspect(view.drawableSize);
    
    [this->view setSampleCount: 2];
    this->view.device = (__bridge id<MTLDevice>)device;
    
    onStart();
}

void SnowSoup::setView(MTKView *view) {
    this->view = view;
}

void SnowSoup::initDevice() {
    device = MTL::CreateSystemDefaultDevice();
}

void SnowSoup::addNode(Node* newNode) {
    sceneTree->AddChild(newNode);
    
    Node* stack[256], *current;
    int sp = 0;
    
    stack[sp] = newNode;
    
    do {
        current = stack[sp];
        
        if (current->isCollider) {
            allColliders->push_back(dynamic_cast<Collider*>(current));
//            baseOcNode->addCollider(dynamic_cast<Collider*>(current));
        }
        
        sp--;
        
        for (int i = 0; i < current->childrenCount; i++) {
            sp++;
            stack[sp] = current->children[i];
        }
        
    } while (sp >= 0);
}

void SnowSoup::run() {
    CollisionManager::getInstance()->collideAllBoxes(allColliders);
    update();
    renderer->drawSetup(view);
    renderer->draw(view, sceneTree);
    renderer->endDraw(view);
}

void SnowSoup::setCameraAspect(CGSize size) {
    renderer->setCameraAspect(size.width / size.height);
    renderer->createDepthAndTargetTextures(size.width, size.height);
}

void SnowSoup::update() {}

void SnowSoup::onStart() {}

