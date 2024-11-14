//
//  Model.cpp
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 27/08/24.
//

#include "Model.hpp"

Model::Model(MTL::Device* device) {
    this->device = device;
    
    texture = new Texture(device);
//    texture->importTexture("Models/textures.png");
}

void Model::importTexture(const char* filepath) {
    texture->importTexture(filepath);
}

void Model::importModel(const std::string filename) {
    Assimp::Importer importer;
    
    const aiScene* scene = importer.ReadFile(
                                             filename,
                                             aiProcess_CalcTangentSpace |
                                             aiProcess_Triangulate);

    if (scene == nullptr) {
        printf("%s\n", importer.GetErrorString());
        
        assert(scene != nullptr);
    }
    
    MeshNode* baseNode = new MeshNode;
    
    getVertexAmount(scene);
    
    if (vertices != nullptr)
        delete vertices;
    vertices = new simd::float3[totalVertexAmount];

    if (textureVertices != nullptr)
        delete textureVertices;
    textureVertices = new simd::float2[totalVertexAmount];
    
    if (normals != nullptr)
        delete normals;
    normals = new simd::float3[totalVertexAmount];
    
    readModelNodeTree(baseNode, scene->mRootNode, scene, scene->mRootNode->mTransformation);
    
    this->baseNode = baseNode;
    
    buildBuffers();
    buildMaterials(scene);
}

void Model::readModelNodeTree(MeshNode* node, aiNode* assimpNode, const aiScene* scene, aiMatrix4x4 carriedTransform) {
    unsigned int* mIndices;
    aiMesh* currentAiMesh;
    Mesh* currentSnowMesh;
    MeshNode* newNode;
    aiMatrix4x4 newTransform;
    
    node->meshCount = assimpNode->mNumMeshes;
    
    if (assimpNode->mNumMeshes > 0) {
        node->meshes = new Mesh*[node->meshCount];
        
        mIndices = assimpNode->mMeshes;
        
        for (int i = 0; i < node->meshCount; i++) {
            currentAiMesh = scene->mMeshes[mIndices[i]];
            currentSnowMesh = new Mesh;
            currentSnowMesh->materialIndex = currentAiMesh->mMaterialIndex;
            setMesh(currentSnowMesh, currentAiMesh, scene);
            node->meshes[i] = currentSnowMesh;
        }
    }
//    newTransform = carriedTransform;
//    newTransform *= assimpNode->mTransformation;
    newTransform = assimpNode->mTransformation;
    memcpy(node->name, assimpNode->mName.data, sizeof(char) * assimpNode->mName.length);
    
    setMeshNodeTransformation(newTransform, node);
    node->extractRotation();
    
//    printf("%lf %lf %lf\n", node->rotation.x, node->rotation.y, node->rotation.z);
    
//    printf("%d\n", assimpNode->mNumChildren);
    
    for (int i = 0; i < assimpNode->mNumChildren; i++) {
        newNode = new MeshNode;
        node->AddChild(newNode);
        readModelNodeTree(newNode, assimpNode->mChildren[i], scene, newTransform);
    }
}

void Model::setMesh(Mesh* mesh, aiMesh* assimpMesh, const aiScene* scene) {
    aiVector3D currentAiVertex, currentAiNormal;

    for (int i = 0; i < assimpMesh->mNumVertices; i++) {
        currentAiVertex = assimpMesh->mVertices[i];
        currentAiNormal = assimpMesh->mNormals[i];
        
        vertices[i + numVertices].x = currentAiVertex.x;
        vertices[i + numVertices].y = currentAiVertex.y;
        vertices[i + numVertices].z = currentAiVertex.z;
        
        normals[i + numVertices].x = currentAiNormal.x;
        normals[i + numVertices].y = currentAiNormal.y;
        normals[i + numVertices].z = currentAiNormal.z;
        
        if (assimpMesh->HasTextureCoords(0)) {
            textureVertices[i + numVertices].x = assimpMesh->mTextureCoords[0][i].x;
            textureVertices[i + numVertices].y = assimpMesh->mTextureCoords[0][i].y;
            numTextVertices++;
        }
    }
    
    mesh->indices = new UInt32[assimpMesh->mNumFaces * 3];
    
    for (int i = 0; i < assimpMesh->mNumFaces; i++) {
        aiFace* currentFace;
        
        currentFace = &assimpMesh->mFaces[i];
        
        for (int j = 0; j < currentFace->mNumIndices; j++)
            mesh->indices[mesh->indexAmount + j] = currentFace->mIndices[j] + (UInt32)numVertices;
        mesh->indexAmount += currentFace->mNumIndices;
    }
    
    numVertices += assimpMesh->mNumVertices;
}

void Model::getVertexAmount(const aiScene* scene) {
    for (int i = 0; i < scene->mNumMeshes; i++)
        totalVertexAmount += scene->mMeshes[i]->mNumVertices;
}

void Model::setMeshNodeTransformation(aiMatrix4x4 transform, MeshNode* node) {
    node->transformation.columns[0][0] = transform.a1;
    node->transformation.columns[0][1] = transform.b1;
    node->transformation.columns[0][2] = transform.c1;
    node->transformation.columns[0][3] = transform.d1;
    
    node->transformation.columns[1][0] = transform.a2;
    node->transformation.columns[1][1] = transform.b2;
    node->transformation.columns[1][2] = transform.c2;
    node->transformation.columns[1][3] = transform.d2;
    
    node->transformation.columns[2][0] = transform.a3;
    node->transformation.columns[2][1] = transform.b3;
    node->transformation.columns[2][2] = transform.c3;
    node->transformation.columns[2][3] = transform.d3;
    
    node->transformation.columns[3][0] = transform.a4;
    node->transformation.columns[3][1] = transform.b4;
    node->transformation.columns[3][2] = transform.c4;
    node->transformation.columns[3][3] = transform.d4;
}

void Model::buildBuffers() {
    MeshNode* currentMeshNode = nullptr;
    MeshNode* stack[256];
    for (int i = 0; i < 256; i++)
        stack[i] = nullptr;
    int stackPtr = 0;
    
    const size_t sizeOfVertexBuffer = numVertices * sizeof(simd::float3);
    const size_t sizeOfNormalBuffer = sizeOfVertexBuffer;
    const size_t sizeOfTxtVtxBuffer = numTextVertices * sizeof(simd::float2);
    
    normalsBuffer = device->newBuffer(sizeOfNormalBuffer, MTL::ResourceStorageModeManaged);
    vertexBuffer = device->newBuffer(sizeOfVertexBuffer, MTL::ResourceStorageModeManaged);
    textureBuffer = device->newBuffer(sizeOfTxtVtxBuffer, MTL::ResourceStorageModeManaged);
    
    memcpy(normalsBuffer->contents(), normals, sizeOfNormalBuffer);
    memcpy(vertexBuffer->contents(), vertices, sizeOfVertexBuffer);
    memcpy(textureBuffer->contents(), textureVertices, sizeOfTxtVtxBuffer);
    
    stack[0] = baseNode;
    stackPtr++;
    
    while (stackPtr > 0) {
        for (int i = 0; i < stack[stackPtr - 1]->meshCount; i++) {
            Mesh* currentMesh = stack[stackPtr - 1]->meshes[i];
            const size_t sizeOfIndexBuffer = currentMesh->indexAmount * sizeof(UInt32);
    
            currentMesh->indexBuffer = device->newBuffer(sizeOfIndexBuffer, MTL::ResourceStorageModeManaged);
            memcpy(currentMesh->indexBuffer->contents(), currentMesh->indices, sizeOfIndexBuffer);
    
            currentMesh->indexBuffer->didModifyRange(NS::Range::Make( 0, currentMesh->indexBuffer->length() ));
        }
        
        currentMeshNode = stack[stackPtr - 1];
        stack[stackPtr - 1] = nullptr;
        stackPtr--;
        
        for (int i = 0; i < currentMeshNode->childrenCount; i++) {
            stack[stackPtr] = dynamic_cast<MeshNode*>(currentMeshNode->children[i]);
            stackPtr++;
        }
    }

    normalsBuffer->didModifyRange(NS::Range::Make(0, normalsBuffer->length()));
    vertexBuffer->didModifyRange(NS::Range::Make(0, vertexBuffer->length()));
    textureBuffer->didModifyRange(NS::Range::Make(0, textureBuffer->length()));
}

void Model::buildMaterials(const aiScene* scene) {
    materials.resize(scene->mNumMaterials);
    
    for (int i = 0; i < scene->mNumMaterials; ++i) {
        aiString textname;
        aiColor3D color;
        float opacity = 0.5f;
//        aiTexture* texture;
//        aiTexel* texel;
//        char numString[1023];
//        int textnum = 0;
        
        scene->mMaterials[i]->Get(AI_MATKEY_COLOR_DIFFUSE, color);
        scene->mMaterials[i]->Get(AI_MATKEY_OPACITY, opacity);
        materials[i].color[0] = color.r;
        materials[i].color[1] = color.g;
        materials[i].color[2] = color.b;
        materials[i].color[3] = opacity;
        printf("%f\n", opacity);
        
        if (scene->mMaterials[i]->GetTextureCount(aiTextureType_DIFFUSE) <= 0)
            continue;
        
        if (scene->mMaterials[i]->GetTexture(aiTextureType_DIFFUSE, 0, &textname) == AI_SUCCESS) {
            char* prs_lst;
            char* prs = strtok(textname.data, "/");
            prs_lst = prs;
            while (prs != NULL) {
                prs_lst = prs;
                prs = strtok(NULL, "/");
            }
//            char* prsex = strtok(prs_lst, ".");
            char* prsex = prs_lst + 1;
            while (*prsex != '.')
                ++prsex;
            *prsex = '\0';
            ++prsex;
            
            NSString *nsname = [NSString stringWithCString:prs_lst encoding:NSASCIIStringEncoding];
            NSString *nsext = [NSString stringWithCString:prsex encoding:NSASCIIStringEncoding];
            NSString *dot = @".";
            nsext = [dot stringByAppendingString:nsext];
            
            materials[i].texture = new Texture(device);
            materials[i].texture->importTexture(SnowFiles::getPath(nsname, nsext));
        }
    }
}

void Model::renderTL(MTL::RenderCommandEncoder* pEnc, Snow_Uniforms* uniforms, Snow_PhongUniforms* phongUniforms, Snow_FStates* allShaders) {
    MeshNode* currentMeshNode = nullptr;
    MeshNode* stack[256];
    for (int i = 0; i < 256; i++)
        stack[i] = nullptr;
    int stackPtr = 0;
    
    pEnc->setVertexBuffer(vertexBuffer, 0, 0);
    pEnc->setVertexBuffer(normalsBuffer, 0, 1);
    
//    pEnc->setFragmentTexture(materials[0].texture->texture, 0);
    pEnc->setFragmentBytes(phongUniforms, sizeof(Snow_PhongUniforms), NS::UInteger(1));
    
    stack[0] = baseNode;
    stackPtr++;
    
    uniforms->modelMatrix = TransformMatrix();
    uniforms->rotationMatrix = RotationMatrix(false);
    
    Snow_Uniforms* localUniforms = new Snow_Uniforms;
    
    while (stackPtr > 0) { 
        simd::float4x4 translationMatrix;
        simd::float4x4 rotationMatrix;
        
        translationMatrix = uniforms->modelMatrix;
//        translationMatrix *= stack[stackPtr - 1]->transformation;
        translationMatrix *= stack[stackPtr - 1]->TransformMatrix();
        
        rotationMatrix = stack[stackPtr - 1]->RotationMatrix(true);
//        rotationMatrix *= stack[stackPtr - 1]->rotationMatrix;
        
        localUniforms->modelMatrix = translationMatrix;
        localUniforms->projectionMatrix = uniforms->projectionMatrix;
        localUniforms->viewMatrix = uniforms->viewMatrix;
        localUniforms->rotationMatrix = uniforms->rotationMatrix * rotationMatrix;
        
        for (int i = 0; i < stack[stackPtr - 1]->meshCount; i++) {
            Mesh* currentMesh = stack[stackPtr - 1]->meshes[i];
            if (materials[currentMesh->materialIndex].texture != NULL) {
                pEnc->setRenderPipelineState(allShaders->litTextured.pipelineState);
                pEnc->setDepthStencilState(allShaders->litTextured.depthState);
                pEnc->setVertexBuffer(textureBuffer, 0, 2);
                pEnc->setVertexBytes(localUniforms, sizeof(Snow_Uniforms), 3);
                pEnc->setFragmentTexture(materials[currentMesh->materialIndex].texture->texture, 0);
            } else {
                pEnc->setRenderPipelineState(allShaders->litSolidColor.pipelineState);
                pEnc->setDepthStencilState(allShaders->litSolidColor.depthState);
                pEnc->setVertexBytes(localUniforms, sizeof(Snow_Uniforms), 2);
                pEnc->setFragmentBytes(&materials[currentMesh->materialIndex].color, sizeof(simd_float4), NS::UInteger(0));
            }
            pEnc->drawIndexedPrimitives(MTL::PrimitiveTypeTriangle, currentMesh->indexAmount, MTL::IndexTypeUInt32, currentMesh->indexBuffer, 0);
        }
        
        currentMeshNode = stack[stackPtr - 1];
        stack[stackPtr - 1] = nullptr;
        stackPtr--;
        
        for (int i = 0; i < currentMeshNode->childrenCount; i++) {
            stack[stackPtr] = static_cast<MeshNode*>(currentMeshNode->children[i]);
            stackPtr++;
        }
    }
    
    delete localUniforms;
}

void Model::renderSCL(MTL::RenderCommandEncoder* pEnc, Snow_Uniforms* uniforms, Snow_PhongUniforms* phongUniforms) {
    MeshNode* currentMeshNode = nullptr;
    MeshNode* stack[256];
    for (int i = 0; i < 256; i++)
        stack[i] = nullptr;
    int stackPtr = 0;
    
    pEnc->setVertexBuffer(vertexBuffer, 0, 0);
    pEnc->setVertexBuffer(normalsBuffer, 0, 1);
    
    pEnc->setFragmentBytes(&color, sizeof(simd_float4), NS::UInteger(1));
    pEnc->setFragmentBytes(phongUniforms, sizeof(Snow_PhongUniforms), NS::UInteger(2));
    
    stack[0] = baseNode;
    stackPtr++;
    
    uniforms->modelMatrix = TransformMatrix();
    uniforms->rotationMatrix = RotationMatrix(false);
    
    Snow_Uniforms* localUniforms = new Snow_Uniforms;
    
    while (stackPtr > 0) {
        simd::float4x4 translationMatrix;
        simd::float4x4 rotationMatrix;
        
        translationMatrix = uniforms->modelMatrix;
//        translationMatrix *= stack[stackPtr - 1]->transformation;
        translationMatrix *= stack[stackPtr - 1]->TransformMatrix();
        
        rotationMatrix = stack[stackPtr - 1]->RotationMatrix(true);
//        rotationMatrix *= stack[stackPtr - 1]->rotationMatrix;
        
        localUniforms->modelMatrix = translationMatrix;
        localUniforms->projectionMatrix = uniforms->projectionMatrix;
        localUniforms->viewMatrix = uniforms->viewMatrix;
        localUniforms->rotationMatrix = uniforms->rotationMatrix * rotationMatrix;
        pEnc->setVertexBytes(localUniforms, sizeof(Snow_Uniforms), 2);
        
        for (int i = 0; i < stack[stackPtr - 1]->meshCount; i++) {
            Mesh* currentMesh = stack[stackPtr - 1]->meshes[i];
            pEnc->drawIndexedPrimitives(MTL::PrimitiveTypeTriangle, currentMesh->indexAmount, MTL::IndexTypeUInt32, currentMesh->indexBuffer, 0);
        }
        
        currentMeshNode = stack[stackPtr - 1];
        stack[stackPtr - 1] = nullptr;
        stackPtr--;
        
        for (int i = 0; i < currentMeshNode->childrenCount; i++) {
            stack[stackPtr] = static_cast<MeshNode*>(currentMeshNode->children[i]);
            stackPtr++;
        }
    }
    
    delete localUniforms;
}

void Model::Draw(MTL::RenderCommandEncoder* pEnc, Snow_Uniforms* uniforms, Snow_PhongUniforms* phongUniforms, Snow_FStates* allShaders) {
    
    pEnc->setCullMode(MTL::CullModeBack);
    pEnc->setFrontFacingWinding(MTL::WindingCounterClockwise);
    
    if (type == TEXTURE_LIT) {
        renderTL(pEnc, uniforms, phongUniforms, allShaders);
    } else if (type == SOLID_COLOR_LIT) {
        pEnc->setRenderPipelineState(allShaders->litSolidColor.pipelineState);
        pEnc->setDepthStencilState(allShaders->litSolidColor.depthState);
        renderSCL(pEnc, uniforms, phongUniforms);
    } else {
        printf("Models only support TEXTURE_LIT or SOLID_COLOR_LIT shader types\n");
        exit(EXIT_FAILURE);
    }
}

