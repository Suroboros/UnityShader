Shader "Custom/Refracting" {
	Properties {
		_CubeMap("Cube Map", Cube) = "" {}
		_RefractionRatio("Refraction Ratio", float) = 0.5
	}
	SubShader {
		Pass {
			Tags { 
				"Queue"="Transparent"
				"RenderType"="Transparent" 
			}
			LOD 200

			CGPROGRAM

			#pragma vertex VertShader
			#pragma fragment FragShader

			#include "UnityCG.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			samplerCUBE _CubeMap;
			float _RefractionRatio;

			struct VertexInputType{
				float4 position : POSITION;
				float3 normal : NORMAL;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float3 posInWorld : TEXCOORD1;float3 refractDir : TEXCOORD2;
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
				float3 refractDirection;
				float3 viewDirection = normalize(input.posInWorld.xyz-_WorldSpaceCameraPos);
				float k = 1.0 - _RefractionRatio * _RefractionRatio * (1.0 - dot(input.normal, viewDirection) * dot(input.normal, viewDirection));
				if(k < 0.0)
				{
					refractDirection = 0;
				}
				else
				{
					refractDirection = _RefractionRatio * viewDirection - (_RefractionRatio * dot(input.normal, viewDirection) + sqrt(k)) * input.normal;
				}
				//refractDirection = refract(viewDirection, input.normal, _RefractionRatio);
				//float4 color = texCUBE(_CubeMap,refractDirection);
				float4 color = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, refractDirection);

				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
