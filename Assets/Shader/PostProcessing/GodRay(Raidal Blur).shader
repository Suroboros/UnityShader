Shader "Custom/GodRay(Raidal Blur)"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BlurTex ("Blur", 2D) = "white" {}
        
    }
    SubShader
    {
        // Extract hight light
		Pass{
			CGPROGRAM

			#pragma vertex VertShader
			#pragma fragment FragShader

            #include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType
			{
				float4 position : POSITION;
				float2 texCoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float2 texCoord : TEXCOORD;
                float4 lightInScreen : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
            float _GodRayRange;
            float4 _ColorThreshold;
            float _LuminancePow;
			sampler2D _CameraDepthTexture;
			float _DepthThreshold;

			FragmentInputType VertShader(VertexInputType input){
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.texCoord = input.texCoord;

                output.lightInScreen = mul(UNITY_MATRIX_V,_WorldSpaceLightPos0);

				return output;
			}

			float4 FragShader (FragmentInputType input) : SV_TARGET{
				float4 color = tex2D(_MainTex, input.texCoord);
				// Get the color which only in godray range
				float distanceThreshold = saturate(_GodRayRange-length(input.lightInScreen.xy-input.texCoord));
				float4 thresholdColor = saturate(color - _ColorThreshold) * distanceThreshold;
                // Luminance
                float luminance = pow(0.298912 * thresholdColor.r + 0.586611 * thresholdColor.g + 0.114478 * thresholdColor.b, _LuminancePow);
				// Depth
				float depth = tex2D(_CameraDepthTexture,input.texCoord).r;
				depth = Linear01Depth(depth);
				// Render pixel whose depth is larger the depth threshold
				luminance *= sign(saturate(depth - _DepthThreshold));
                return float4(luminance,luminance,luminance,1.0f);
			}
			ENDCG
		}

		// Raidal blur
		Pass{
			CGPROGRAM

			#pragma vertex VertShader
			#pragma fragment FragShader

            #include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType
			{
				float4 position : POSITION;
				float2 texCoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float2 texCoord : TEXCOORD;
                float2 raidalOffset : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
            float _raidalWeight;
			int _raidalSampleRate;

			FragmentInputType VertShader(VertexInputType input){
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.texCoord = input.texCoord;

                output.raidalOffset = (mul(UNITY_MATRIX_V,_WorldSpaceLightPos0).xy-input.texCoord)*_raidalWeight;

				return output;
			}

			float4 FragShader (FragmentInputType input) : SV_TARGET{
				float4 color = float4(0,0,0,0);
				for(int i=0;i<_raidalSampleRate;i++)
				{
					color += tex2D(_MainTex,input.texCoord);
					input.texCoord += input.raidalOffset;
				}
				color = color/_raidalSampleRate;
				
                return color;
			}
			ENDCG
		}

		// God Ray
		Pass{
			CGPROGRAM

			#pragma vertex VertShader
			#pragma fragment FragShader

            #include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType
			{
				float4 position : POSITION;
				float2 texCoord : TEXCOORD;
			};

			struct FragmentInputType
			{
				float4 position : SV_POSITION;
				float2 texCoord : TEXCOORD;
                float2 blurTexCoord : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
            sampler2D _BlurTex;
			float4 _godRayColor;

			FragmentInputType VertShader(VertexInputType input){
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.texCoord = input.texCoord;

                output.blurTexCoord = input.texCoord;
				#if UNITY_UV_STARTS_AT_TOP // DirectX
				if (_MainTex_TexelSize.y < 0)
				{
					output.blurTexCoord.y = 1 - output.blurTexCoord.y;
				}
				#endif

				return output;
			}

			float4 FragShader (FragmentInputType input) : SV_TARGET{
				float4 originColor = tex2D(_MainTex,input.texCoord);
				float4 blurColor = tex2D(_BlurTex,input.blurTexCoord) * _godRayColor;
				
				float4 color = originColor + blurColor;
				
                return color;
			}
			ENDCG
		}
    }
}
