Shader "Custom/TowSideLighting" {
	Properties {
		_FrontKa ("Front Ka", Range(0,1)) = 1
		_FrontColor ("Front Color", Color) = (1,1,1,1)
		_FrontSpecularColor ("Front Specular Color", Color) = (1,1,1,1)
		_FrontShininess ("Front Specular Shininess", float) = 1
		_BackKa ("Back Ka", Range(0,1)) = 1
		_BackColor ("Back Color", Color) = (1,1,1,1)
		_BackSpecularColor ("Back Specular Color", Color) = (1,1,1,1)
		_BackShininess ("Back Specular Shininess", float) = 1
	}
	SubShader {
		Pass{
			Tags { "LightMode" = "ForwardBase" } 
			Cull Back

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
			float _FrontKa;
			fixed4 _FrontColor;
			fixed4 _FrontSpecularColor;
			float _FrontShininess;

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
				float3 ambient = _FrontKa * lightColor * _FrontColor.rgb;
				// Diffuse
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float lightIntensity = max(dot(input.normal,lightDirection), 0);
				float3 diffuse = _FrontColor.rgb * lightColor * lightIntensity;
				// Specular
				float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
				float3 halfDirection = normalize(lightDirection + viewDirection);
				float specularLight = pow(max(dot(halfDirection,input.normal) , 0), _FrontShininess);
				if(lightIntensity <= 0) specularLight = 0;
				float3 specular = _FrontSpecularColor.rgb * lightColor * specularLight;
				// Final color
				float3 color = ambient + diffuse + specular;
				return float4(color,1.0);
			}
			ENDCG
		}

		Pass{
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One
			Cull Back

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
			float _FrontKa;
			fixed4 _FrontColor;
			fixed4 _FrontSpecularColor;
			float _FrontShininess;

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
				//float3 ambient = _FrontKa * lightColor * _FrontColor.rgb;
				// Diffuse	
				float attenuation;
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
				float3 diffuse = attenuation * _FrontColor.rgb * lightColor * lightIntensity;
				// Specular
				float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
				float3 halfDirection = normalize(lightDirection + viewDirection);
				float specularLight = pow(max(dot(halfDirection,input.normal) , 0), _FrontShininess);
				if(lightIntensity <= 0) specularLight = 0;
				float3 specular = attenuation * _FrontSpecularColor.rgb * lightColor * specularLight;
				// Final color
				float3 color = diffuse + specular;
				return float4(color,1.0);
			}
			ENDCG
		}

		Pass{
			Tags { "LightMode" = "ForwardBase" } 
			Cull Front

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
			float _BackKa;
			fixed4 _BackColor;
			fixed4 _BackSpecularColor;
			float _BackShininess;

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
				output.normal = normalize(mul(float4(-input.normal,0),worldInverse).xyz);

				return output;
			}
			
			fixed4 TextureFragmentShader (FragmentInputType input) : SV_Target
			{
				// Light Color
				float3 lightColor = _LightColor0.rgb;
				// Emissive
				//float4 emissive = _EmissiveColor;
				// Ambient
				float3 ambient = _BackKa * lightColor * _BackColor.rgb;
				// Diffuse
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float lightIntensity = max(dot(input.normal,lightDirection), 0);
				float3 diffuse = _BackColor.rgb * lightColor * lightIntensity;
				// Specular
				float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
				float3 halfDirection = normalize(lightDirection + viewDirection);
				float specularLight = pow(max(dot(halfDirection,input.normal) , 0), _BackShininess);
				if(lightIntensity <= 0) specularLight = 0;
				float3 specular = _BackSpecularColor.rgb * lightColor * specularLight;
				// Final color
				float3 color = ambient + diffuse + specular;
				return float4(color,1.0);
			}
			ENDCG
		}

		Pass{
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One
			Cull Front

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
			float _BackKa;
			fixed4 _BackColor;
			fixed4 _BackSpecularColor;
			float _BackShininess;

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
				output.normal = normalize(mul(float4(-input.normal,0),worldInverse).xyz);

				return output;
			}
			
			fixed4 TextureFragmentShader (FragmentInputType input) : SV_Target
			{
				// Light Color
				float3 lightColor = _LightColor0.rgb;
				// Emissive
				//float4 emissive = _EmissiveColor;
				// Ambient
				//float3 ambient = _BackKa * lightColor * _BackColor.rgb;
				// Diffuse	
				float attenuation;
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
				float3 diffuse = attenuation * _BackColor.rgb * lightColor * lightIntensity;
				// Specular
				float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
				float3 halfDirection = normalize(lightDirection + viewDirection);
				float specularLight = pow(max(dot(halfDirection,input.normal) , 0), _BackShininess);
				if(lightIntensity <= 0) specularLight = 0;
				float3 specular = attenuation * _BackSpecularColor.rgb * lightColor * specularLight;
				// Final color
				float3 color = diffuse + specular;
				return float4(color,1.0);
			}
			ENDCG
		}
	}
	FallBack "Specula"
}
