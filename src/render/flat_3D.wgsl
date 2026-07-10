// (C) Copyright 2025 Matyas Constans
// Licensed under the MIT License (https://opensource.org/license/mit/)

struct World_3D_Type {
  @align(16) World_View_Projection   : mat4x4<f32>,
  @align(16) World_Inverse_Transpose : mat4x4<f32>,
  @align(16) World                   : mat4x4<f32>,
  @align(16) Eye_Position            : vec3<f32>,
  @align(16) Color                   : vec4<f32>,
};

struct Instance {
  @align(16) Transform  : mat4x4<f32>,
  @align(16) Color      : vec4<f32>,
};

@group(0) @binding(0) var<storage, read> X_Buffer         : array<vec4<f32>>;
@group(0) @binding(1) var<storage, read> U_Buffer         : array<vec2<f32>>;
@group(0) @binding(2) var<storage, read> N_Buffer         : array<vec4<f32>>;
@group(0) @binding(3) var Texture                         : texture_2d<f32>;
@group(0) @binding(4) var Sampler                         : sampler;
@group(0) @binding(5) var<uniform> World_3D               : World_3D_Type;
@group(0) @binding(6) var<storage, read> I_Buffer         : array<Instance>;

fn vec4_unpack_u32(packed: u32) -> vec4<f32> {
  let r = f32((packed >> 0)  & 0xFFu) / 255.0;
  let g = f32((packed >> 8)  & 0xFFu) / 255.0;
  let b = f32((packed >> 16) & 0xFFu) / 255.0;
  let a = f32((packed >> 24) & 0xFFu) / 255.0;

  return vec4<f32>(r, g, b, a);
}

struct VS_Out {
    @builtin(position)  X : vec4<f32>,
    @location(0)        U : vec2<f32>,
    @location(1)        C : vec4<f32>,
};

@vertex
fn vs_main(@builtin(vertex_index) idx : u32, @builtin(instance_index) instance : u32) -> VS_Out {
   var out : VS_Out;

   let X = X_Buffer[idx];
   let U = U_Buffer[idx];
   let I = I_Buffer[instance];

   out.X = transpose(World_3D.World_View_Projection) * transpose(I.Transform) * X;
   out.U = U;
   out.C = I.Color;

   return out;
}

@fragment
fn fs_main(@location(0) U : vec2<f32>, @location(1) C : vec4<f32>) -> @location(0) vec4<f32> {
  let color = C * World_3D.Color * textureSample(Texture, Sampler, U);
  return color;
}

