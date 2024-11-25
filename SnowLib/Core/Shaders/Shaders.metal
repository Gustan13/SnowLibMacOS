//
//  Shaders.metal
//  SnowSoup
//
//  Created by Guilherme de Souza Barci on 03/09/24.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4x4 rotationMatrix;
};

struct v2f
{
    float4 position [[position]];
    float3 normal;
    float2 texturePosition;
};

struct v1f
{
    float4 position [[position]];
};

v2f vertex vertexMain( uint vertexId [[vertex_id]],
                       device const float3* positions [[buffer(0)]],
                      device const float3* normals [[buffer(1)]],
                       device const float2* texturePositions [[buffer(2)]],
                        constant Uniforms &uniforms[[buffer(3)]])
{
    float4 fixedInPosition = float4( positions[ vertexId ], 1.0);
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * fixedInPosition;
    float2 texturePosition = texturePositions[ vertexId ];
    
    v2f o;
    o.position = position;
    o.normal = (uniforms.rotationMatrix * float4(normals[vertexId], 1.0)).xyz;
//    o.normal = normals[vertexId];
    o.texturePosition = texturePosition;
    return o;
}

v2f vertex vertexSolidMain( uint vertexId [[vertex_id]],
                       device const float3* positions [[buffer(0)]],
                      device const float3* normals [[buffer(1)]],
                        constant Uniforms &uniforms[[buffer(2)]])
{
    float4 fixedInPosition = float4( positions[ vertexId ], 1.0);
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * fixedInPosition;
    
    v2f o;
    o.position = position;
    o.normal = (uniforms.rotationMatrix * float4(normals[vertexId], 1.0)).xyz;
    return o;
}

v1f vertex vertexPr( uint vertexId [[vertex_id]],
                       device const float3* positions [[buffer(0)]],
                        constant Uniforms &uniforms[[buffer(1)]])
{
    float4 fixedInPosition = float4( positions[ vertexId ], 1.0);
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * fixedInPosition;
    
    v1f o;
    o.position = position;
    return o;
}

float4 fragment fragmentMain( v2f in [[stage_in]], texture2d<float> texture [[texture(0)]] )
{
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    const float4 colorSample = texture.sample(textureSampler, in.texturePosition);
    
    return colorSample;
}

float4 fragment fragmentPr( v1f in [[stage_in]],
                           device const float3* inc[[buffer(1)]])
{
    return float4(inc[0], 1.f);
}


