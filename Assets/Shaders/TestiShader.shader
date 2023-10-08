Shader "Custom/TestiShader"
{
    Properties
    {
        _Color ("Coloriii", Color) = (1,1,1,1)
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

            struct Attributes
            {
                float3 positionOS : POSITION;
                half3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalOS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            CBUFFER_END
            

            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalOS = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }

            half4 Frag(const Varyings input) : SV_TARGET
            {
                half4 color = 0;
                color.rgb = input.normalOS * 0.5 + 0.5;
                return color;
                //return _Color * clamp(input.positionWS.x,0,1 );
                
            }
            ENDHLSL
        }
    }
}