Shader "Custom/MultiplicativeBlend" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "Queue" = "Transparent" } 
		LOD 200
		Pass{
			Cull Front
			ZWrite Off
			Blend DstColor Zero

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType{
				float4 position : POSITION;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
			};

			float4 _Color;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				return _Color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
