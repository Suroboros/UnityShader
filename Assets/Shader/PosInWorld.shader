// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PosInWorld" {
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass{
			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType
			{
				float4 position : POSITION;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float4 pos_in_world : TEXCOORD;
			};

			FragmentInputType VertShader(VertexInputType input) {
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.pos_in_world = mul(unity_ObjectToWorld, input.position);
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET{
				// float dist = distance(input.pos_in_world,float4(0,0,0,1));
				// if(dist<5.0f)
				// {
				// 	return float4(0,0,0,1);
				// }
				// else
				// {
				// 	return float4(1,1,1,1);
				// }
				// return float4(1,1,1,1);
				return input.pos_in_world;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
