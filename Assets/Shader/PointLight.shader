// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PointLight" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Pass{
			Tags { "LightMode" = "ForwardBase" } // ForwardBase must be directional light
			CGPROGRAM

			#pragma vertex VertShader
			#pragma fragment FragShader

			#include "UnityCG.cginc"

			uniform float4 _LightColor0;
			uniform float4 _Color;

			struct VertexInputType {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct FragmentInputType {
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
			};

			FragmentInputType VertShader(VertexInputType input) {
				FragmentInputType output;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.pos = UnityObjectToClipPos(input.vertex);

				// Normal Transform
				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);
				
				return output;

			}

			float4 FragShader(FragmentInputType input) : SV_TARGET {
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// Diffuse
				float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(input.normal,lightDir));
				//float3 diffuse = _LightColor0.rgb;
                float4 color = float4(diffuse,1.0);

				return color;
			}

			ENDCG
		}

		Pass{
			Tags {"LightMode" = "ForwardAdd" }
			Blend One One

			CGPROGRAM

			#pragma vertex VertShader
			#pragma fragment FragShader

			#include "UnityCG.cginc"

			uniform float4 _LightColor0;
			uniform float4 _Color;

			struct VertexInputType {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct FragmentInputType {
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float4 posInWorld : TEXCOORD;
			};

			FragmentInputType VertShader(VertexInputType input) {
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.pos = UnityObjectToClipPos(input.vertex);
				output.posInWorld = mul(world, input.vertex);

				// Normal Transform
				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);
				
				return output;

			}

			float4 FragShader(FragmentInputType input) : SV_TARGET {
				// If light is directional light, attenuation will be 1. While attenuation is one_over_distance when light is point light.
				float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - input.posInWorld.xyz;
				float one_over_distance = 1.0 / length(vertexToLightSource);
				float attenuation = lerp(1.0,one_over_distance,_WorldSpaceLightPos0.w);
				float3 lightDir = normalize(vertexToLightSource);

				// Diffuse
				float3 diffuse = attenuation * _LightColor0.rgb * _Color.rgb * max(0, dot(input.normal,lightDir));
                float4 color = float4(diffuse,1.0);

				return color;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
