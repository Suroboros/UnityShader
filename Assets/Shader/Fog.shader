Shader "Custom/Fog" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_FogColor ("Fog Color", Color) = (1,1,1,1)
		_FogDensity ("Fog Density", float) = 0.01
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass{

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex vertShader
			#pragma fragment fragShader

			#include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _FogColor;
			uniform float _FogDensity;

			struct VertexInputType
			{
				float4 position : POSITION;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float4 texcoord : TEXCOORD;
				float4 posInWorld : TEXCOORD1;
				float3 posInView : TEXCOORD2;
			};

			FragmentInputType vertShader(VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				
				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);
				output.posInWorld = mul(world, input.position);
				//output.posInView = mul(UNITY_MATRIX_MV, input.position).xyz;
				output.posInView = UnityObjectToViewPos(input.position).xyz;

				// Texture
				output.texcoord = input.texcoord;

				return output;
			}

			float4 fragShader(FragmentInputType input) : SV_TARGET
			{
				// Fog distance
				float fogDistance = length(input.posInView);
				// Fog Factor
				float fogFactor = exp2(-abs(fogDistance * _FogDensity));
				
				// Texture
				float4 texColor = tex2D(_MainTex,input.texcoord);
				float4 color = float4(lerp(_FogColor,texColor.rgb,fogFactor), texColor.w);
			
				return color;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
