Shader "Custom/SimpleBlend" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Color1 ("Color1", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		//Tags { "RenderType"="Opaque" }
		Tags { "Queue" = "Transparent" } 
		LOD 200
		Pass{
			Cull Front
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

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

		Pass{
			Cull Back
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

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

			float4 _Color1;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				return _Color1;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
