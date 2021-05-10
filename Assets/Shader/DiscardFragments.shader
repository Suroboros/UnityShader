// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DiscardFragments" {
	Properties {
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass{
			Cull Front
			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType{
				float4 position : POSITION;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float4 posInObjCords : TEXCOORD;
			};

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.posInObjCords = input.position;
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				if(input.posInObjCords.y<0)
				{
					discard;
				}
				return float4(1,0,0,1);
			}
			ENDCG
		}

		Pass{
			Cull Back
			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType{
				float4 position : POSITION;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float4 posInObjCords : TEXCOORD;
			};

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				output.position = UnityObjectToClipPos(input.position);
				output.posInObjCords = input.position;
				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				if(input.posInObjCords.y>0)
				{
					discard;
				}
				return float4(0,1,0,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
