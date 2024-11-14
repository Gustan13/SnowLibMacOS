//
//  Model.hpp
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 27/08/24.
//

#ifndef Model_hpp
#define Model_hpp

#include <Metal/Metal.hpp>
#include <simd/simd.h>
#include <string.h>

#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>

#include "Mesh.hpp"
#include "SnowStructs.h"
#include "Texture.hpp"
#include "SnowMaterial.hpp"
#include "Transform.hpp"
#include "MeshNode.hpp"
#include "SnowFiles.hpp"

#include <Cocoa/Cocoa.h>

class Model : public Transform {
public:
    Model(MTL::Device* device);
    void importModel(const std::string filename);
    void importTexture(const char* filepath);
    void renderTL(MTL::RenderCommandEncoder* pEnc, Snow_Uniforms* uniforms, Snow_PhongUniforms* phongUniforms, Snow_FStates* allShaders);
    void renderSCL(MTL::RenderCommandEncoder* pEnc, Snow_Uniforms* uniforms, Snow_PhongUniforms* phongUniforms);
    
    void Draw( MTL::RenderCommandEncoder* pEnc, Snow_Uniforms* uniforms, Snow_PhongUniforms* phongUniforms, Snow_FStates* allShaders ) override;
    MeshNode* baseNode;
    ShaderType type = TEXTURE_LIT;
    simd_float4 color = {0.f,0.f,0.f,0.f};
private:
    MTL::Device* device;
    MTL::Buffer* vertexBuffer;
    MTL::Buffer* textureBuffer;
    MTL::Buffer* normalsBuffer;
    
    Mesh** meshes;
//    MeshNode* baseNode;
    simd::float2* textureVertices = nullptr;
    simd::float3* vertices = nullptr;
    simd::float3* normals = nullptr;
    
    size_t numMeshes = 0;
    size_t numVertices = 0;
    size_t numTextVertices = 0;
    
    size_t totalVertexAmount = 0;
    
    Texture* texture = nullptr;
    std::vector<SnowMaterial> materials;
    
    void readModelNodeTree(MeshNode* node, aiNode* assimpNode, const aiScene* scene, aiMatrix4x4 carriedTransform);
    void setMesh(Mesh* mesh, aiMesh* assimpMesh, const aiScene* scene);
    void setMeshNodeTransformation(aiMatrix4x4 transform, MeshNode* node);
    void getVertexAmount(const aiScene* scene);
    
    void buildMaterials(const aiScene* scene);
    void buildBuffers();
};

#endif /* Model_hpp */
