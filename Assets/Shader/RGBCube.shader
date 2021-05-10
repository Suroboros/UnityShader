// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/RGBCube" {
	SubShader {
		Pass{
			CGPROGRAM

			#pragma vertex TextureVertexShader
			#pragma fragment TextureFragmentShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType
			{
				float4 position : POSITION;
				float3 normal   : NORMAL;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float4 color : TEXCOORD;
				float3 normal : NORMAL;
			};

			FragmentInputType TextureVertexShader(VertexInputType input){
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.color = input.position + float4(0.5,0.5,0.5,0);
				output.normal = input.normal;
				return output;
			}

			float4 TextureFragmentShader (FragmentInputType input) : SV_TARGET{
				float4 color;
				//color.r = (input.color.r+input.color.g+input.color.b)/3.0f;
				//color.g = (input.color.r+input.color.g+input.color.b)/3.0f;
				//color.b = (input.color.r+input.color.g+input.color.b)/3.0f;
				color = input.color;
				//color = float4((input.normal+ float3(1.0, 1.0, 1.0))/2.0,1.0);
				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
