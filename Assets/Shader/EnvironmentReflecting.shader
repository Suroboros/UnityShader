Shader "Custom/EnvironmentReflecting" {
	Properties {
		_CubeMap("Cube Map", Cube) = "" {}
	}
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

			samplerCUBE _CubeMap;

			struct VertexInputType{
				float4 position : POSITION;
				float3 normal : NORMAL;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float3 posInWorld : TEXCOORD1;
			};

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);
				output.posInWorld = mul(world, input.position);

				// Normal Transform
				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);

				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				// Reflecting
				float3 viewDirection = normalize(input.posInWorld.xyz-_WorldSpaceCameraPos);
				float3 ReflectedDirection = reflect(viewDirection,input.normal);
				//float4 color = texCUBE(_CubeMap,ReflectedDirection);
				float4 color = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, ReflectedDirection);//Unity only

				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
