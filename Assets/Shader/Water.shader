Shader "Custom/Water" {
	Properties {
		_WaterColor ("Water Color", Color) = (0.3,0.5,0.9,0.5)
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		_Refraction ("Refraction", Range(0,1)) = 0.12
		_FresnelFactor ("Fresnel Factor", Range(0,1)) = 0.5
	}
	SubShader {
		Tags { 
			"Queue"="Transparent"
			"RenderType"="Transparent" 
		}

		GrabPass{ }

		Pass{
			//Tags { "LightMode" = "ForwardBase" } 
			ZWrite Off // off depth buffer in order not to occlude other objects

			// Alpha blending
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex VertShader
			#pragma fragment FragShader

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			float4 _WaterColor;
			float _Refraction;
			sampler2D _GrabTexture;
			sampler2D _NoiseTexture;
			float4 _NoiseTexture_ST;
			float _FresnelFactor;

			struct VertexInputType
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 posInWorld : TEXCOORD1;
				float4 screenUV : TEXCOORD2;
				float3 tangent : TANGENT;
				float3 binormal : TEXCOORD3;
			};


			FragmentInputType VertShader (VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);
				output.posInWorld = mul(world, input.position);

				// Normal Transform
				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);
				// Tangent Transform
				output.tangent = normalize(mul(world,float4(input.tangent.xyz,0)).xyz);
				// Binormal
				output.binormal = normalize(cross(output.normal,output.tangent) * input.tangent.w);// Only unity use tangent w

				// UV
				output.texcoord = input.texcoord;

				// Calculate screen uv
				#if UNITY_UV_STARTS_AT_TOP  // if Direct3D
					float scale = -1; // flipped projection matrix
				#else						// if OpenGL
					float scale = 1; // flipped projection matrix
				#endif
				float4 temp = output.position * 0.5;
				#if defined(UNITY_HALF_TEXEL_OFFSET) // Dx9
					output.screenUV.xy = float2(1, scale) * temp.xy + temp.w * _ScreenParams.zw;
				#else
					output.screenUV.xy = float2(1, scale) * temp.xy + temp.w; // OpenGL 1, Direct3D -1
				#endif
				output.screenUV.zw = output.position.zw;

				return output;
			}
			
			fixed4 FragShader (FragmentInputType input) : SV_Target
			{
				// Refraction
				// Noise
				float2 offsetByTime = frac(float2(1 , 0) * _Time);
				float4 noise = tex2D(_NoiseTexture, _NoiseTexture_ST.xy * (input.texcoord.xy + offsetByTime) + _NoiseTexture_ST.zw);
				float3 noiseCood = 2 * noise.rgb - float3(1,1,1);
				// Tangent space to world space matrix
				float3x3 T2WMaxtrix = float3x3(input.tangent,input.binormal,input.normal);
				float3 noiseDirection = normalize(mul(noiseCood, T2WMaxtrix));
				float2 screenUV_offset = noiseDirection.rg * _Refraction;
				// Screen texture
				float4 screenTex = tex2D(_GrabTexture, input.screenUV.xy/input.screenUV.w + screenUV_offset);

				// Reflection
				float3 viewDirection = normalize(input.posInWorld.xyz-_WorldSpaceCameraPos);
				float3 ReflectedDirection = reflect(viewDirection,noiseDirection);
				float4 reflectColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, ReflectedDirection);

				// Fresnel reflaction
				float fresnel = saturate(_FresnelFactor + (1 - _FresnelFactor) * pow(1 - dot(-viewDirection, input.normal),5));
				float4 fresnelColor = lerp(screenTex, reflectColor,fresnel);

				return fresnelColor;
			}
			ENDCG
		}

	}
	//FallBack "Diffuse"
}
