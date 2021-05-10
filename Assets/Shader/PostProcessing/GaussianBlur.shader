Shader "Custom/GaussianBlur"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off
        ZWrite Off

        // Down sample
        Pass{
            ZTest Off

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
                float2 texCoordLU : TEXCOORD1; // left up
                float2 texCoordRU : TEXCOORD2; // right up
                float2 texCoordLD : TEXCOORD3; // left down
                float2 texCoordRD : TEXCOORD4; // right down
			};

			sampler2D _MainTex;
	        float4 _MainTex_TexelSize;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
                output.texCoordLU = input.texCoord.xy + _MainTex_TexelSize * float2(-0.5,0.5);
                output.texCoordRU = input.texCoord.xy + _MainTex_TexelSize * float2(0.5,0.5);
                output.texCoordLD = input.texCoord.xy + _MainTex_TexelSize * float2(-0.5,-0.5);
                output.texCoordRD = input.texCoord.xy + _MainTex_TexelSize * float2(0.5,-0.5);

				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
                float4 color = tex2D(_MainTex,input.texCoordLU);
                color += tex2D(_MainTex,input.texCoordRU);
                color += tex2D(_MainTex,input.texCoordLD);
                color += tex2D(_MainTex,input.texCoordRD);
                color = color / 4;

				return color;
			}
			ENDCG
        }

        // Gaussian blur
        Pass{
            ZTest Always

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

            #include "UnityCG.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

            // Gaussian kernel
            static const float GaussianKernel[7] =
            {
                0.0205, 0.0855, 0.232, 0.324, 0.232, 0.0855, 0.0205
            };


			struct VertexInputType{
				float4 position : POSITION;
                float2 texCoord : TEXCOORD;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
                float2 texCoord : TEXCOORD;
                float2 texOffset : TEXCOORD1;
			};

			sampler2D _MainTex;
	        float4 _MainTex_TexelSize;
            float2 _offset;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
                output.texCoord = input.texCoord;

                output.texOffset = _MainTex_TexelSize.xy * _offset;
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
                // Start from center 3 offset away
                float2 curTexCoord = input.texCoord - input.texOffset * 3.0;
                float4 color = 0;
                // Gaussian processing
                for(int i =0; i <7; i++)
                {
                    color += tex2D(_MainTex,curTexCoord) * GaussianKernel[i];
                    curTexCoord += input.texOffset;
                }

				return color;
			}
			ENDCG
		}
    }
}
