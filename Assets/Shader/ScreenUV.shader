Shader "Custom/ScreenUV" {
	Properties {
		_MainTex ("Texture Image", 2D) = "white" {}
	}
	SubShader {
		GrabPass{ }
		Pass{

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex vertShader
			#pragma fragment fragShader

			#include "UnityCG.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _GrabTexture;

			struct VertexInputType
			{
				float4 position : POSITION;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float4 texcoord : TEXCOORD;
				float4 screenUV : TEXCOORD1;
			};

			FragmentInputType vertShader(VertexInputType input)
			{
				FragmentInputType output;

				output.position = UnityObjectToClipPos(input.position);
				output.texcoord = input.texcoord;

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

				//output.screenUV = ComputeScreenPos(output.position); // Build in function

				return output;
			}

			float4 fragShader(FragmentInputType input) : SV_TARGET
			{
				//return tex2D(_MainTex,input.texcoord);
				//return tex2D(_GrabTexture,input.texcoord);
				//return tex2D(_GrabTexture,input.screenUV.xy/input.screenUV.w);
				return tex2Dproj(_GrabTexture,input.screenUV);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
