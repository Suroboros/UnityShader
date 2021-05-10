Shader "Custom/ScreenDistortion" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		// Wave
		Pass{
			CGPROGRAM

			#pragma vertex TextureVertexShader
			#pragma fragment TextureFragmentShader

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
			};

			float _offsetFactor;
			float _distortRatio;
			float _distortWidth;
			float _curDistance;
			float _timeRatio;
			float2 _mousePos;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			FragmentInputType TextureVertexShader(VertexInputType input){
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.texCoord = input.texCoord;

				return output;
			}

			float4 TextureFragmentShader (FragmentInputType input) : SV_TARGET{
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				{
					_mousePos.y = 1 - _mousePos.y;
				}
				#endif
				float4 color;
				// Out diffusion
				//float2 vecFromCenter = float2(0.5,0.5) - input.texCoord;
				float2 vecFromCenter = _mousePos.xy - input.texCoord;
				vecFromCenter = vecFromCenter * float2(_ScreenParams.x / _ScreenParams.y, 1); // Aspect ratio
				//float2 newTexCoord = input.texCoord + offset;
				float distanceFromCenter = sqrt(vecFromCenter.x*vecFromCenter.x+vecFromCenter.y*vecFromCenter.y);
				float sinFactor = sin(distanceFromCenter * _offsetFactor - _Time * _timeRatio)* _distortRatio * 0.01f;
				//float widthFactor = abs(_curDistance-vecFromCenter);
				float widthFactor = clamp(_distortWidth-abs(_curDistance-distanceFromCenter),0,1);
				float2 offset = normalize(vecFromCenter) * sinFactor * widthFactor;
				float2 newTexCoord = input.texCoord + offset;
				color = tex2D(_MainTex, newTexCoord);
				//color = float4((input.normal+ float3(1.0, 1.0, 1.0))/2.0,1.0);
				return color;
			}
			ENDCG
		}

		// Under water
		Pass{
			CGPROGRAM

			#pragma vertex TextureVertexShader
			#pragma fragment TextureFragmentShader

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
			};

			float _offsetFacotr;
			float _distortRatio;
			float _timeRatio;
			sampler2D _MainTex;

			FragmentInputType TextureVertexShader(VertexInputType input){
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.texCoord = input.texCoord;

				return output;
			}

			float4 TextureFragmentShader (FragmentInputType input) : SV_TARGET{
				float4 color;
				
				float2 vecFromCenter = float2(0.f-input.texCoord.x,0);
				float distanceFromCenter = sqrt(vecFromCenter.x*vecFromCenter.x+vecFromCenter.y*vecFromCenter.y);
				float sinFactor = sin(distanceFromCenter * _offsetFacotr - _Time * _timeRatio)* _distortRatio * 0.01f;
				float2 offset = normalize(vecFromCenter) * sinFactor;
				float2 newTexCoord = input.texCoord + float2(sinFactor,0);
				color = tex2D(_MainTex, newTexCoord);
				//color = float4((input.normal+ float3(1.0, 1.0, 1.0))/2.0,1.0);
				return color;
			}
			ENDCG
		}
	}
}
