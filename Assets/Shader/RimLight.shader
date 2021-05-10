Shader "Custom/RimLight"
{
    Properties {
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimColorPower ("Rim Color Power", Range(0,1)) = 0.5
        _Texture ("Texture", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "2D" {}
	}
	SubShader {
		Tags { "RenderType" = "Opaque" } 
		LOD 200
		Pass{

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex VertShader
			#pragma fragment FragShader

            #include "Lighting.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct VertexInputType{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
                float2 texCoord : TEXCOORD;
			};

			struct FragmentInputType{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
				float3 binormal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
                float2 texCoord : TEXCOORD;
			};

			float4 _RimColor;
			float _RimColorPower;
            sampler _Texture;
			sampler2D _NormalTex;
			float4 _NormalTex_ST;

			FragmentInputType VertShader(VertexInputType input)
			{
				FragmentInputType output;
				float4x4 world = unity_ObjectToWorld;
				float4x4 worldInverse = unity_WorldToObject;

				output.position = UnityObjectToClipPos(input.position);

				output.normal = normalize(mul(float4(input.normal,0),worldInverse).xyz);
				output.tangent = normalize(mul(world,float4(input.tangent.xyz,0)).xyz);
				output.binormal = normalize(cross(output.normal,output.tangent) * input.tangent.w);// Only unity use tangent w
				
				output.viewDir = normalize(_WorldSpaceCameraPos-mul(world,input.position).xyz);
                output.texCoord = input.texCoord;

				return output;
			}

			float4 FragShader(FragmentInputType input) : SV_TARGET
			{
				// Decode normal texture
				float4 normalTex = tex2D(_NormalTex, _NormalTex_ST.xy * input.texCoord.xy + _NormalTex_ST.zw );
				float3 normalCood = 2 * normalTex.rgb - float3(1,1,1);

				// Tangent space to world space matrix
				float3x3 T2WMaxtrix = float3x3(input.tangent,input.binormal,input.normal);
				// Transfrom normal texture to world
				float3 normalDirection = normalize(mul(normalCood, T2WMaxtrix));

				float4 textureColor = tex2D(_Texture,input.texCoord);
				//float r = pow(abs(dot(input.viewDir, input.normal)),_RimColorPower);
				float r = pow(abs(dot(input.viewDir, normalDirection)),_RimColorPower);
				return lerp(_RimColor,textureColor,r);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
