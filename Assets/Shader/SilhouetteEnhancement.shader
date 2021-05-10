Shader "Custom/SilhouetteEnhancement" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Thickness ("Thickness", Range(0,1)) = 0.5
	}
	SubShader {
		Tags { "Queue" = "Transparent" } 
		LOD 200
		Pass{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType{
				float4 position : POSITION;
				float3 normal : NORMAL;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD;
			};

			float4 _Color;
			float _Thickness;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);

				output.normal = normalize(mul(float4(input.normal,0),unity_WorldToObject).xyz);
				output.viewDir = normalize(_WorldSpaceCameraPos-mul(unity_ObjectToWorld,input.position).xyz);

				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				//float newAlpha = min(1.0f,_Color.a/abs(dot(normalize(input.viewDir),normalize(input.normal))));
				float newAlpha = min(1.0f,_Color.a/pow(abs(dot(normalize(input.viewDir),normalize(input.normal))),_Thickness));
				return float4(_Color.rgb,newAlpha);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
