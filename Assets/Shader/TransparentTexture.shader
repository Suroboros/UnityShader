Shader "Custom/TransparentTexture" {

	// Cut off method
	// Properties {
	// 	_MainTex ("Albedo (RGB)", 2D) = "white" {}
	// 	_CutOff ("Cut Off", Range(0,1)) = 0.5
	// }
	// SubShader {
	// 	Tags { "RenderType"="Opaque" }
	// 	LOD 200

	// 	Pass{
	// 		Cull OFF
	// 		CGPROGRAM
	// 		// Physically based Standard lighting model, and enable shadows on all light types
	// 		#pragma vertex VertShader
	// 		#pragma fragment FragShader

	// 		// Use shader model 3.0 target, to get nicer looking lighting
	// 		#pragma target 3.0

	// 		struct VertexInputType{
	// 			float4 position : POSITION;
	// 			float4 texcoord : TEXCOORD;
	// 		};

	// 		struct FragmentInputType{
	// 			float4 position : SV_POSITION;
	// 			float4 texcoord : TEXCOORD0;
	// 			float4 posInWorld : TEXCOORD1;
	// 		};

	// 		sampler2D _MainTex;
	// 		float _CutOff;

	// 		FragmentInputType VertShader(VertexInputType input)
	// 		{
	// 			FragmentInputType output;
	// 			float4x4 world = unity_ObjectToWorld;
	// 			float4x4 worldInverse = unity_WorldToObject;

	// 			// Vertex Transform
	// 			output.position = UnityObjectToClipPos(input.position);
	// 			output.posInWorld = mul(world, input.position);

	// 			// Texture
	// 			output.texcoord = input.texcoord;

	// 			return output;
	// 		}

	// 		float4 FragShader(FragmentInputType input) : SV_TARGET
	// 		{
	// 			float4 tex = tex2D(_MainTex, input.texcoord.xy);
	// 			if(tex.a < _CutOff)
	// 			{
	// 				discard;
	// 			}
	// 			return tex;
	// 		}
	// 		ENDCG
	// 	}
	// }


	// Blending method
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Range ("Range", Range(0,1)) = 0.5
		_Alpha ("Alpha", Range(0,1)) = 0.5
	}
	SubShader {
		Tags { "Queue"="Transparent" }

		Pass{
			Cull Front
			ZWrite Off // off depth buffer in order not to occlude other objects

			// Alpha blending
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType{
				float4 position : POSITION;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float4 texcoord : TEXCOORD;
			};

			sampler2D _MainTex;
			float _Range;
			float _Alpha;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);

				// Texture
				output.texcoord = input.texcoord;

				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				float4 tex = tex2D(_MainTex, input.texcoord.xy);
				if(tex.a < _Range) tex = float4(0,0,1.0,_Alpha);
				return tex;
			}
			ENDCG
		}

		Pass{
			Cull Back
			ZWrite Off // off depth buffer in order not to occlude other objects

			// Alpha blending
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType{
				float4 position : POSITION;
				float4 texcoord : TEXCOORD;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float4 texcoord : TEXCOORD;
			};

			sampler2D _MainTex;
			float _Range;
			float _Alpha;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				// Vertex Transform
				output.position = UnityObjectToClipPos(input.position);

				// Texture
				output.texcoord = input.texcoord;

				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				float4 tex = tex2D(_MainTex, input.texcoord.xy);
				if(tex.a < _Range) tex = float4(0,0,1.0,_Alpha);
				return tex;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
