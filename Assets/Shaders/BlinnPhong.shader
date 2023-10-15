Shader "Custom/BlinnPhong"
{
    Properties
    {
        _Color ("Colori", Color) = (1,1,1,1)
        _Metallic("Metallic", float) = 1
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            CBUFFER_END


            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                return output;
            }

            half4 BlinnPhong(Varyings input)
            {
                
                
                Light l  = GetMainLight();
                half3 amb = 0.1*l.color;
                half3 diffuse = saturate(dot(input.normalWS, l.direction)) * l.color;
                half3 dir = GetWorldSpaceNormalizeViewDir(input.positionWS);
                half3 halfvector = normalize(l.direction + dir);
                half3 spec = pow(saturate(dot(input.normalWS, halfvector)),_Metallic) * l.color;
                return float4((amb + diffuse + spec) * _Color, 1);
                
            }

            half4 Frag(const Varyings input) : SV_TARGET
            {
                return BlinnPhong(input);

            }
            ENDHLSL
        }
    }
}