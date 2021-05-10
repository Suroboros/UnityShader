Shader "Custom/TowSeparatedTextures" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Separation ("Separation", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		pass{
			CGPROGRAM
			#pragma vertex TextureVertexShader
			#pragma fragment TextureFragmentShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;

			struct VertexInputType
			{
				float4 position : POSITION;
				float2 texCoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float2 leftTexCoord : TEXCOORD;
				float2 rightTexCoord : TEXCOORD1;
			};

			fixed4 _Color;
			float _Separation;

			FragmentInputType TextureVertexShader (VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.leftTexCoord = -(input.texCoord - float2(_Separation,0));
				output.rightTexCoord = -(input.texCoord + float2(_Separation,0));
				return output;
			}
			
			fixed4 TextureFragmentShader (FragmentInputType input) : SV_Target
			{
				float4 color = _Color;
				float4 leftColor=tex2D(_MainTex, input.leftTexCoord);
				float4 rightColor = tex2D(_MainTex, input.rightTexCoord);
				color = lerp(leftColor,rightColor,0.5);
				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
