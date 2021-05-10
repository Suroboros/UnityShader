Shader "Custom/ColorShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		
	}
	SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex TextureVertexShader
            #pragma fragment TextureFragmentShader

			float4 _Color;

			struct VertexInputType
			{
				float4 position : POSITION;
			};

            struct FragmentInputType
			{
				float4 position : SV_POSITION;
			};

            FragmentInputType TextureVertexShader (VertexInputType input)
            {
                FragmentInputType output;
                output.position = input.position;
                return output;
            }
            
            fixed4 TextureFragmentShader (FragmentInputType i) : SV_Target
            {
                float4 color = _Color;
				return color;
            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}
