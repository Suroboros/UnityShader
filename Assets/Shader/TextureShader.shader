Shader "Custom/TextureShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Twist("Twist", FLOAT) = 1.0
	}
	SubShader {

		pass
		{
		
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
				float2 texCoord : TEXCOORD;
			};

			fixed4 _Color;
			float _Twist;

			FragmentInputType TextureVertexShader (VertexInputType input)
			{
				FragmentInputType output;
				float angle = _Twist*length(input.position);
				float cosLength, sinLength;
				sincos(angle, sinLength, cosLength);
				//output.position = input.position;
				output.position[0] = cosLength * input.position[0] - sinLength * input.position[1];
				output.position[1] = sinLength * input.position[0] + cosLength * input.position[1];
				output.position[2] = input.position[2];
				output.position[3] = input.position[3];
				output.texCoord = -input.texCoord;
				return output;
			}
			
			fixed4 TextureFragmentShader (FragmentInputType input) : SV_Target
			{
				float4 color = _Color;
				color=tex2D(_MainTex, input.texCoord);
				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
