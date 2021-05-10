Shader "Custom/LightingTexture" {
	// Separate Specular
	Properties {
		_Ka ("Ka", Range(0,1)) = 1
		_MaterialColor ("Material Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess ("Specular Shininess", float) = 1
	}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM
			
			#pragma vertex vertShader
			#pragma fragment fragShader 

			#include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType {
				float4 position : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType {
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 posInWorld : TEXCOORD1;
			};

			float _Ka;
			fixed4 _MaterialColor;
			sampler2D _MainTex;
			fixed4 _SpecularColor;
			float _Shininess;

			FragmentInputType vertShader (VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);
				output.posInWorld = mul(world, input.position);

				// Normal Transform
				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);

				// Texture
				output.texcoord = input.texcoord;

				return output;
			}
			
			fixed4 fragShader (FragmentInputType input) : SV_Target
			{
				// Light Color
				float3 lightColor = _LightColor0.rgb;
				// Emissive
				//float4 emissive = _EmissiveColor;
				// Ambient
				float3 ambient = _Ka * lightColor * _MaterialColor.rgb;
				// Diffuse
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float lightIntensity = max(dot(input.normal,lightDirection), 0);
				float3 diffuse = _MaterialColor.rgb * lightColor * lightIntensity;
				// Specular
				float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
				float3 halfDirection = normalize(lightDirection + viewDirection);
				float specularLight = pow(max(dot(halfDirection,input.normal) , 0), _Shininess);
				if(lightIntensity <= 0) specularLight = 0;
				float3 specular = _SpecularColor.rgb * lightColor * specularLight;
				// Final color
				float3 color = ambient + diffuse * tex2D(_MainTex, input.texcoord.xy) + specular;
				return float4(color,_MaterialColor.w);
			}
			ENDCG
		}

		Pass{
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One

			CGPROGRAM

			#pragma vertex vertShader
			#pragma fragment fragShader 

			#include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType {
				float4 position : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType {
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 posInWorld : TEXCOORD1;
			};

			float _Ka;
			fixed4 _MaterialColor;
			sampler2D _MainTex;
			fixed4 _SpecularColor;
			float _Shininess;

			//sampler2D _MainTex;

			FragmentInputType vertShader (VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);
				output.posInWorld = mul(world, input.position);

				// Normal Transform
				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);

				// Texture
				output.texcoord = input.texcoord;

				return output;
			}
			
			fixed4 fragShader (FragmentInputType input) : SV_Target
			{
				// Light Color
				float3 lightColor = _LightColor0.rgb;
				// Emissive
				//float4 emissive = _EmissiveColor;
				// Ambient
				//float3 ambient = _Ka * lightColor * _MaterialColor.rgb;
				// Diffuse
				float3 vertexToLight = _WorldSpaceLightPos0.xyz - input.posInWorld.xyz;
				float one_over_distance = 1.0 / length(vertexToLight);
				float attenuation = lerp(1,one_over_distance,_WorldSpaceLightPos0.w);
				float3 lightDirection = normalize(vertexToLight);

				if (0.0 == _WorldSpaceLightPos0.w) // directional light?
				{
					attenuation = 1.0; // no attenuation
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				} 
				else // point or spot light
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
						- input.posInWorld.xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance; // linear attenuation 
					lightDirection = normalize(vertexToLightSource);
				}

				float lightIntensity = max(dot(input.normal,lightDirection), 0);
				float3 diffuse = attenuation * _MaterialColor.rgb * lightColor * lightIntensity;
				// Specular
				float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
				float3 halfDirection = normalize(lightDirection + viewDirection);
				float specularLight = pow(max(dot(halfDirection,input.normal) , 0), _Shininess);
				if(lightIntensity <= 0) specularLight = 0;
				float3 specular = attenuation * _SpecularColor.rgb * lightColor * specularLight;
				// Final color
				float3 color = diffuse * tex2D(_MainTex, input.texcoord.xy) + specular;
				return float4(color,_MaterialColor.w);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
