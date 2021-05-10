Shader "Custom/MultiteTexture" {
	Properties {
		_Threshold ("Threshold", Range(0,1)) = 1
		_MainTex ("Main Texture", 2D) = "white" {}
		_SecTex ("Second Texture", 2D) = "white" {}
	}
	SubShader {
		Pass{
			Tags { "LightMode" = "ForwardBase" } 

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex vertShader
			#pragma fragment fragShader

			#include "UnityCG.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			uniform sampler2D _MainTex;
			uniform sampler2D _SecTex;
			uniform float _Threshold;
			uniform float4 _LightColor0; 

			struct VertexInputType
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD;
			};

			FragmentInputType vertShader(VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);

				// Normal Transform
				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);

				// Texture
				output.texcoord = input.texcoord;

				return output;
			}

			float4 fragShader(FragmentInputType input) : SV_TARGET
			{
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float lightIntensity = max(dot(input.normal,lightDirection), 0);
				
				//float4 unlitColor = tex2D(_MainTex, input.texcoord.xy) * _LightColor0;
				float4 unlitColor = tex2D(_MainTex, input.texcoord.xy) * _Threshold;  // Control the brightness by color filter
            	float4 sunlitColor = tex2D(_SecTex, input.texcoord.xy) * _LightColor0;    
            	return lerp(unlitColor, sunlitColor, lightIntensity);// sunlitColor * lightIntensity + unlitColor * (1.0 - lightIntensity)

			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
