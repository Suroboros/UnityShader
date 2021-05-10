Shader "Custom/ParallaxMapping" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "bump" {}
		_ParallaxTex("Parallax", 2D) = "black" {}
		_ParallaxBound("Parallax Bound", Range(0,1)) = 1
		_MaxNomalOffset("Max Normal Offset", float) = 0.01
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess ("Specular Shininess", float) = 10
	}

	CGINCLUDE
	
	#include "Lighting.cginc"

	// Use shader model 3.0 target, to get nicer looking lighting
	#pragma target 3.0

	struct VertexInputType {
		float4 position : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float4 texcoord : TEXCOORD;
	};

	struct FragmentInputType {
		float4 position : SV_POSITION;
		float3 normal : NORMAL;
		float3 tangent : TANGENT;
		float3 binormal : TEXCOORD2;
		float4 texcoord : TEXCOORD0;
		float4 posInWorld : TEXCOORD1;
		float3 viewDirInTangent : TEXCOORD3;
	};

	sampler2D _MainTex;
	sampler2D _NormalTex;
	float4 _NormalTex_ST;
	sampler2D _ParallaxTex;
	float4 _ParallaxTex_ST;
	float _ParallaxBound;
	float _MaxNomalOffset;
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

		// Tangent Transform
		output.tangent = normalize(mul(world,float4(input.tangent.xyz,0)).xyz);

		// Binormal
		output.binormal = normalize(cross(output.normal,output.tangent) * input.tangent.w);// Only unity use tangent w
		//binormalLocal = normalize(cross(input.normal,input.tangent) * input.tangent.w);

		// World space to tangent space matrix
		float3x3 W2TMaxtrix = transpose(float3x3(output.tangent,output.binormal,output.normal));
		// Transform view vector
		float3 viewDirection = normalize(_WorldSpaceCameraPos-output.posInWorld.xyz);
		output.viewDirInTangent = normalize(mul(W2TMaxtrix,viewDirection));

		// Texture
		output.texcoord = input.texcoord;

		return output;
	}
	
	fixed4 fragShader (FragmentInputType input) : SV_Target
	{
		// Calculate normal offset
		float height = tex2D(_ParallaxTex, _ParallaxTex_ST.xy * input.texcoord.xy + _ParallaxTex_ST.zw).x - 0.5;
		float2 normalCoordOffset = clamp(_ParallaxBound * height * input.viewDirInTangent.xy / input.viewDirInTangent.z, -_MaxNomalOffset, _MaxNomalOffset);

		// Decode normal texture
		float4 normalTex = tex2D(_NormalTex, _NormalTex_ST.xy * (input.texcoord.xy + normalCoordOffset) + _NormalTex_ST.zw );
		float3 normalCood = 2 * normalTex.rgb - float3(1,1,1);

		// Tangent space to world space matrix
		float3x3 T2WMaxtrix = float3x3(input.tangent,input.binormal,input.normal);
		// Transfrom normal texture to world
		float3 normalDirection = normalize(mul(normalCood, T2WMaxtrix));

		// Light Color
		float3 lightColor = _LightColor0.rgb;
		// Texture
		float4 textureColor = tex2D(_MainTex, input.texcoord.xy);
		// Emissive
		//float4 emissive = _EmissiveColor;
		// Ambient
		float3 ambient = lightColor * textureColor.rgb;
		
		float3 lightDirection;
		float attenuation;
		if (0.0 == _WorldSpaceLightPos0.w) // directional light?
		{
			attenuation = 1.0; // no attenuation
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		} 
		else // point or spot light
		{
			float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - input.posInWorld.xyz;
			float distance = length(vertexToLightSource);
			attenuation = 1.0 / distance; // linear attenuation 
			lightDirection = normalize(vertexToLightSource);
		}
		// Diffuse
		float lightIntensity = max(dot(normalDirection,lightDirection), 0);
		float3 diffuse = attenuation * lightColor * lightIntensity * textureColor.rgb;
		// Specular
		float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
		float3 halfDirection = normalize(lightDirection + viewDirection);
		float specularLight = pow(max(dot(halfDirection,normalDirection) , 0), _Shininess);
		if(lightIntensity <= 0) specularLight = 0;
		float3 specular =  _SpecularColor.rgb * lightColor * specularLight;
		// Final color
		float3 color = ambient + diffuse * textureColor + specular;
		return float4(color,1);
	}

	fixed4 fragShaderWithoutAmbient (FragmentInputType input) : SV_Target
	{
		// Calculate normal offset
		float height = tex2D(_ParallaxTex, _ParallaxTex_ST.xy * input.texcoord.xy + _ParallaxTex_ST.zw).x - 0.5;
		float2 normalCoordOffset = clamp(_ParallaxBound * height * input.viewDirInTangent.xy / input.viewDirInTangent.z, -_MaxNomalOffset, _MaxNomalOffset);

		// Decode normal texture
		float4 normalTex = tex2D(_NormalTex, _NormalTex_ST.xy * (input.texcoord.xy + normalCoordOffset) + _NormalTex_ST.zw );
		float3 normalCood = 2 * normalTex.rgb - float3(1,1,1);

		// Tangent space to world space matrix
		float3x3 T2WMaxtrix = float3x3(input.tangent,input.binormal,input.normal);
		// Transfrom normal texture to world
		float3 normalDirection = normalize(mul(normalCood, T2WMaxtrix));

		// Light Color
		float3 lightColor = _LightColor0.rgb;
		// Texture
		float4 textureColor = tex2D(_MainTex, input.texcoord.xy);
		// Emissive
		//float4 emissive = _EmissiveColor;
		// Ambient
		//float3 ambient = lightColor * _Color.rgb * textureColor.rgb;
		
		float3 lightDirection;
		float attenuation;
		if (0.0 == _WorldSpaceLightPos0.w) // directional light?
		{
			attenuation = 1.0; // no attenuation
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		} 
		else // point or spot light
		{
			float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - input.posInWorld.xyz;
			float distance = length(vertexToLightSource);
			attenuation = 1.0 / distance; // linear attenuation 
			lightDirection = normalize(vertexToLightSource);
		}
		// Diffuse
		float lightIntensity = max(dot(normalDirection,lightDirection), 0);
		float3 diffuse = attenuation * lightColor * lightIntensity * textureColor.rgb;
		// Specular
		float3 viewDirection = normalize(_WorldSpaceCameraPos-input.posInWorld.xyz);
		float3 halfDirection = normalize(-lightDirection + viewDirection);
		float specularLight = pow(max(dot(halfDirection,normalDirection) , 0), _Shininess);
		if(lightIntensity <= 0) specularLight = 0;
		float3 specular =  _SpecularColor.rgb * (1.0 - textureColor.a) * lightColor * specularLight;
		// Final color
		float3 color = diffuse * textureColor + specular;
		return float4(color,1);
	}

	ENDCG

	SubShader {
		Pass {      
         Tags { "LightMode" = "ForwardBase" } 
            // pass for ambient light and first light source
 
         CGPROGRAM
            #pragma vertex vertShader  
            #pragma fragment fragShader  
            // the functions are defined in the CGINCLUDE part
         ENDCG
      }
 
      Pass {      
         Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
         Blend One One // additive blending 
 
         CGPROGRAM
            #pragma vertex vertShader  
            #pragma fragment fragShaderWithoutAmbient  
            // the functions are defined in the CGINCLUDE part
         ENDCG
      }
	}
	FallBack "Diffuse"
}
