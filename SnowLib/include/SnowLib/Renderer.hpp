//
//  Renderer.hpp
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 03/09/24.
//

#ifndef Renderer_hpp
#define Renderer_hpp

#include <cassert>

#include <Metal/Metal.hpp>
#include <MetalKit/MetalKit.h>
#include <QuartzCore/CAMetalDrawable.hpp>
#include <simd/simd.h>

#include "SnowStructs.h"
#include "Model.hpp"

#include "Transform.hpp"
#include "PerspectiveCamera.hpp"
#include "OrthographicCamera.hpp"
#include "DirectionalLight.hpp"

#include "Collider.hpp"

class Renderer
{
public:
    Renderer( MTL::Device* pDevice, std::vector<Collider*>* allColliders, MTKView* view );
    ~Renderer();
    void            drawSetup( MTKView* view );
    void            initDraw( MTKView* view );
    void            draw( MTKView* view, Node* sceneTree );
    void            endDraw( MTKView* view );
    
    Snow_ForwardState       buildShaders(std::string vertex, std::string fragment);
    void                    buildMatrices();
    void                    buildSkybox();
    void                    buildSphere();
    
    void                    createDepthAndTargetTextures(int width, int height);
    
    void                    setCameraAspect(float aspect);
    
    MTL::RenderCommandEncoder*      pEnc;
    Snow_Uniforms                   *uniforms   = new Snow_Uniforms;
    
    float angle = 0.f;
    
    Camera*                         camera;
    
private:
    MTL::Device*                    _pDevice;
    MTL::CommandQueue*              _pCommandQueue;
    MTL::CommandBuffer*             _pCmd;
    MTL::RenderPassDescriptor*      _pRpd;
    
    MTL::RenderPipelineState*       _pPSO;
    MTL::DepthStencilState*         _pDSS;
    
    MTL::RenderPipelineState*       _pPSO2;
    MTL::DepthStencilState*         _pDSS2;
    
    MTL::RenderPipelineState*       _pPSO3;
    MTL::DepthStencilState*         _pDSS3;
    
    MTL::Texture*                   _pRenderTargetTexture = nullptr;
    MTL::Texture*                   _pDepthTexture;
    
    MTL::Buffer*                    _pVertexPositionsBuffer;
    MTL::Buffer*                    _pVertexColorsBuffer;
    MTL::Buffer*                    _pVertexColors2Buffer;
    MTL::Buffer*                    _pVertexNormalsBuffer;
    MTL::Buffer*                    _pIndexBuffer;

    DirectionalLight*               directionalLight;
    
    simd::float3*                   vertices = nullptr;
    UInt32*                         indices = nullptr;
    
    int                             numV = 0;
    int                             numI = 0;
    
    Snow_SkyboxUniforms             *skyUniforms = new Snow_SkyboxUniforms;
    Transform                       *boneco = new Transform;
    Snow_FStates*                   allShaders = new Snow_FStates;
    
    std::vector<Collider*>*          allColliders;
};

#endif /* Renderer_hpp */
