Shader "Custom/CombinedBlend" {
	Properties {
		_FrontColor ("Front Color", Color) = (1,1,1,1)
		_BackColor ("Back Color", Color) = (1,1,1,1)
	}
	SubShader {
	Tags { "Queue" = "Transparent" } 
		LOD 200
		Pass{
			Cull Off
			ZWrite Off
			Blend Zero OneMinusSrcAlpha

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

			float4 _FrontColor;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				return _FrontColor;
			}
			ENDCG
		}

		Pass{
			Cull Off
			ZWrite Off
			Blend SrcAlpha One

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

			float4 _BackColor;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				return _BackColor;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
