Shader "Custom/PlanarReflection" {
	SubShader {
		Pass {
			Tags { "RenderType"="Opaque" }
			LOD 200

			CGPROGRAM

			#pragma vertex VertShader
			#pragma fragment FragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			#include "UnityCG.cginc"

			sampler2D _ReflectTexture;

			struct VertexInputType{
				float4 position : POSITION;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float4 screenUV : TEXCOORD0;
			};

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);
				output.screenUV = ComputeScreenPos(output.position);

				// Calculate screen uv
				#if UNITY_UV_STARTS_AT_TOP  // if Direct3D
					float scale = -1; // flipped projection matrix
				#else						// if OpenGL
					float scale = 1; // flipped projection matrix
				#endif
				float4 temp = output.position * 0.5;
				#if defined(UNITY_HALF_TEXEL_OFFSET) // Dx9
					output.screenUV.xy = float2(1, scale) * temp.xy + temp.w * _ScreenParams.zw;
				#else
					output.screenUV.xy = float2(1, scale) * temp.xy + temp.w; // OpenGL 1, Direct3D -1
				#endif
				output.screenUV.zw = output.position.zw;
		
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				
				float4 color = tex2Dproj(_ReflectTexture,input.screenUV);

				return color;
			}
			ENDCG
		}
	}
	//FallBack "Diffuse"
}
