Shader "Custom/TexShader"
{
    Properties
    {
        _MainTex("Main texture", 2D) = "white" {}
        _NormalMap("Normal map", 2D) = "normal" {}
        _Metallic("Metallic", Range(1,512)) = 1
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

            TEXTURE2D(_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_NormalMap);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalMap_ST;
            float _Metallic;
            CBUFFER_END
            
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                
                float2 uv : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
                float3 bitTangentWS : TEXCOORD5;
                
            };
            
            

            
            
            Varyings Vert(const Attributes input)
            {
                Varyings output;
                // output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
        
                VertexPositionInputs vin = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs vnorm = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionHCS = vin.positionCS;
                output.normalWS = vnorm.normalWS;
                output.tangentWS = vnorm.tangentWS;
                output.bitTangentWS = vnorm.bitangentWS;
                output.uv = input.uv;// * _MainTex_ST.xy + _MainTex_ST.zw + _Time.y * float2(0.5, 1);
                
                return output;
            }
            half4 BlinnPhong(Varyings input, float4 texColor)
            {
                Light l  = GetMainLight();
                half3 amb = 0.1*l.color;
                half3 diffuse = saturate(dot(input.normalWS, l.direction)) * l.color;
                half3 dir = GetWorldSpaceNormalizeViewDir(input.positionWS);
                half3 halfvector = normalize(l.direction + dir);
                half3 spec = pow(saturate(dot(input.normalWS, halfvector)),_Metallic) * l.color;
                
                return float4((amb + diffuse + spec) * texColor, 1);
            }
            
            float4 Frag(Varyings input) : SV_TARGET
            {
                const float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
                const float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(input.uv, _MainTex)));
                const float3x3 tangentToWorld = float3x3(input.tangentWS, input.bitTangentWS, input.normalWS);
                const float3 normalWS = TransformTangentToWorld(normalTS, tangentToWorld, true);
                input.normalWS = normalWS;
                
                return BlinnPhong(input, texColor);
            }

            
            ENDHLSL
        }
    }
}