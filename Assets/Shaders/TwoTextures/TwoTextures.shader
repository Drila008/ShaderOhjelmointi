Shader "Custom/TwoTextures"
{
    Properties
    {
        _MainTex("Texture 1", 2D) = "white" {}
        _SecTex("Texture 2", 2D) = "white" {}
        _Lerp("Lerp", Range(0,1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipleline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "OmaPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            TEXTURE2D(_MainTex);
            TEXTURE2D(_SecTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_SecTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _SecTex_ST;
            float Lerp;
            CBUFFER_END
            
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
            

            
            
            Varyings Vert(const Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);

                
                output.uv = input.uv;
                
                return output;
            }
            
            float4 Frag(const Varyings input) : SV_TARGET
            {
                // Define a lerp factor based on _ModeKeyword.
                

                // Lerp between the two textures using the calculated factor.
                float4 texture1Color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                float4 texture2Color = SAMPLE_TEXTURE2D(_SecTex, sampler_SecTex, input.uv);
                float4 lerpedColor = lerp(texture1Color, texture2Color, Lerp);

                return lerpedColor;
            }

            ENDHLSL
        }
    }
}