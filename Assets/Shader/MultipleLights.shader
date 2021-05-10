Shader "Custom/MultipleLights" {
	Properties {
		//_EmissiveColor ("Emissive Color", Color) = (1,1,1,1)
		//_AmbientColor ("Ambient Color", Color) = (1,1,1,1)
		_Ka ("Ka", Range(0,1)) = 1
		_MaterialColor ("Material Color", Color) = (1,1,1,1)
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess ("Specular Shininess", float) = 1
		//_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		//LOD 200
		Pass{
			Tags { "LightMode" = "ForwardBase" } 

			CGPROGRAM
			#pragma multi_compile_fwdbase 
			#pragma vertex TextureVertexShader
			#pragma fragment TextureFragmentShader

			#include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float4 posInWorld : TEXCOORD;
				float3 vertexLighting : TEXCOORD01;
			};

			//fixed4 _EmissiveColor;
			//fixed4 _AmbientColor;
			fixed4 _MaterialColor;
			fixed4 _SpecularColor;
			float _Ka;
			float _Shininess;

			//sampler2D _MainTex;

			FragmentInputType TextureVertexShader (VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);
				output.posInWorld = mul(world, input.position);

				// Normal Transform
				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);

				// Calculate vertex lighting
				output.vertexLighting = float3(0,0,0);
				#ifdef VERTEXLIGHT_ON
				for(int i = 0; i < 4; i++)
				{
					float3 vLightPos = float3(unity_4LightPosX0[i],unity_4LightPosY0[i],unity_4LightPosZ0[i]);
					float3 vLightColor = unity_LightColor[i].rgb;

					float3 vertexToLight = vLightPos - output.posInWorld.xyz;
					float3 vLightDir = normalize(vertexToLight);
					float sqrDistance = dot(vertexToLight,vertexToLight);
					float attenuation = 1.0/(1.0+unity_4LightAtten0[i]*sqrDistance);
					float3 vDiffuse = attenuation * vLightColor * _MaterialColor.rgb * max(0,dot(output.normal,vLightDir));

					output.vertexLighting += vDiffuse;
				}
				#endif

				return output;
			}
			
			fixed4 TextureFragmentShader (FragmentInputType input) : SV_Target
			{
				// Light Color
				float3 lightColor = _LightColor0.rgb;
				// Emissive
				//float4 emissive = _EmissiveColor;
				// Ambient
				float3 ambient = _Ka * lightColor * _MaterialColor.rgb;
				// Diffuse
				float attenuation;
				//float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 lightDirection;

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
				float3 color = ambient + diffuse + specular + input.vertexLighting;
				return float4(color,_MaterialColor.w);
			}
			ENDCG
		}

		Pass{
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One

			CGPROGRAM
			#pragma vertex TextureVertexShader
			#pragma fragment TextureFragmentShader

			#include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float4 posInWorld : TEXCOORD;
			};

			//fixed4 _EmissiveColor;
			//fixed4 _AmbientColor;
			fixed4 _MaterialColor;
			fixed4 _SpecularColor;
			float _Ka;
			float _Shininess;

			//sampler2D _MainTex;

			FragmentInputType TextureVertexShader (VertexInputType input)
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
			
			fixed4 TextureFragmentShader (FragmentInputType input) : SV_Target
			{
				// Light Color
				float3 lightColor = _LightColor0.rgb;
				// Emissive
				//float4 emissive = _EmissiveColor;
				// Ambient
				//float3 ambient = _Ka * lightColor * _MaterialColor.rgb;
				// Diffuse
				float attenuation;
				//float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 lightDirection;

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

				float lightIntensity = max(0, dot(normalize(input.normal),lightDirection));
				float3 diffuse = attenuation * _MaterialColor.rgb * lightColor * lightIntensity;
				// Specular
				float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
				float3 halfDirection = normalize(lightDirection + viewDirection);
				float specularLight = pow(max(dot(halfDirection,input.normal) , 0), _Shininess);
				if(lightIntensity <= 0) specularLight = 0;
				float3 specular = attenuation * _SpecularColor.rgb * lightColor * specularLight;
				// Final color
				float3 color = diffuse + specular;
				return float4(color,_MaterialColor.w);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
