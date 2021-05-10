Shader "Custom/DepthTexture"
{
    SubShader {
		Cull Off
		ZTest Always
        ZWrite Off
		Pass{
			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

            #include "UnityCG.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType{
				float4 position : POSITION;
                float2 texCoord : TEXCOORD;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
                float2 texCoord : TEXCOORD;
			};

			sampler2D _CameraDepthTexture;
			sampler2D _MainTex;
	        float4 _MainTex_TexelSize;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
                output.texCoord = input.texCoord;

				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				// Get depth
                float depth = tex2D(_CameraDepthTexture,input.texCoord).r;
				depth = Linear01Depth(depth);
				return float4(depth,depth,depth,1);
			}
			ENDCG
		}
	}
}