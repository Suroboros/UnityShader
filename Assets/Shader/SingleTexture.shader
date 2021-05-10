Shader "Custom/SingleTexture" {
	Properties {
		_MainTex ("Texture Image", 2D) = "white" {}
	}
	SubShader {
		Pass{

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex vertShader
			#pragma fragment fragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			struct VertexInputType
			{
				float4 position : POSITION;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float4 texcoord : TEXCOORD;
			};

			FragmentInputType vertShader(VertexInputType input)
			{
				FragmentInputType output;

				output.position = UnityObjectToClipPos(input.position);
				output.texcoord = input.texcoord;

				return output;
			}

			float4 fragShader(FragmentInputType input) : SV_TARGET
			{
				//return tex2D(_MainTex, input.texcoord);
				//return tex2D(_MainTex,_MainTex_ST.xy*input.texcoord.xy+_MainTex_ST.zw);
				
				// Flowing
				float2 offset = frac(float2(1 , 0) * _Time);
				return tex2D(_MainTex,_MainTex_ST.xy*input.texcoord.xy + offset);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
