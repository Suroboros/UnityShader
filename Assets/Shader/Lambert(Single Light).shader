// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Lambert(Single Light)" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		//Tags { "RenderType"="Opaque" }
		//LOD 200
		Pass{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex VertShader
			#pragma fragment FragShader

			#include "UnityCG.cginc"

			uniform float4 _LightColor0;
			uniform float4 _Color;

			struct VertexInputType{
				float4 position : POSITION;
				float3 normal : NORMAL;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
			};

			FragmentInputType VertShader(VertexInputType input){
				FragmentInputType output;
				float4x4 worldMat = unity_ObjectToWorld;
				float4x4 worldMatInverse = unity_WorldToObject;

				output.position = UnityObjectToClipPos(input.position);

				output.normal = normalize(mul(float4(input.normal,0),worldMatInverse)).xyz;
				
				return output;

			}

			float4 FragShader(FragmentInputType input) : SV_TARGET{
				float4 color;
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(input.normal,lightDir));

				color = float4(diffuse,1);

				return color;


			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
