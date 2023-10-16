Shader "Custom/DisplacementShader"
{
    Properties
    {
        _Color ("Coloriii", Color) = (1,1,1,1)
        [KeywordEnum(Local, World, View)]
        _ModeKeyword("Mode", float) = 0
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

            #pragma multi_compile_vertex _MODEKEYWORD_LOCAL _MODEKEYWORD_WORLD _MODEKEYWORD_VIEW
            
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

            
                
                float3 newPosition = input.positionOS;
                newPosition.y += 1;

                #if _MODEKEYWORD_LOCAL
                newPosition = input.positionOS;
                newPosition.y += 1.0;
                output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(newPosition, 1))));
                //output.positionHCS = newPosition;
                
                #elif _MODEKEYWORD_WORLD
                // newPosition = mul(UNITY_MATRIX_M, float4(input.positionOS, 1)).xyz;
                // newPosition.y += 1.0;
                // output.positionWS = newPosition;

                
                #elif _MODEKEYWORD_VIEW
                newPosition = mul(UNITY_MATRIX_M, float4(input.positionOS, 1)).xyz;
                newPosition.y += 1.0;
                #endif

                
                //output.positionWS = newPosition;
                output.normalOS = input.normalOS;

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