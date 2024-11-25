//
//  SnowStructs.h
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 23/08/24.
//

/** @file SnowStructs.h
 *  @brief Defines structs for general use
 */

#ifndef SnowStructs_h
#define SnowStructs_h

#include <simd/simd.h>
#include <Metal/Metal.hpp>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 rotationMatrix;
} Snow_Uniforms;

typedef struct {
    vector_float3 u_LightDir;
    vector_float3 u_LightColor;
    vector_float3 u_SkyColor;
    vector_float3 u_HorizonColor;
    vector_float3 u_GroundColor;
    float u_SunSize;
} Snow_SkyboxUniforms;

typedef struct {
    vector_float3 u_LightDir;
    vector_float3 u_AmbientLightColor;
    vector_float3 u_LightColor;
    vector_float3 u_ViewPosition;
    float u_SpecularIntensity;
} Snow_PhongUniforms;

typedef struct {
    MTL::RenderPipelineState* pipelineState;
    MTL::DepthStencilState* depthState;
} Snow_ForwardState;

typedef struct {
    Snow_ForwardState colliderDebug;
    Snow_ForwardState litTextured;
    Snow_ForwardState litSolidColor;
} Snow_FStates;

typedef struct
{
    double w, x, y, z;
} Quaternion;

typedef enum {
    TEXTURE_LIT,
    SOLID_COLOR_LIT,
    DEBUG_COLLIDER
} ShaderType;

#endif /* SnowStructs_h */
