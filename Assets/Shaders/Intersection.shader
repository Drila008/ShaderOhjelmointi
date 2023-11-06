Shader "Custom/Intersection"
{
     Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {
            Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

           

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _IntersectionColor;
            CBUFFER_END


            struct Attributes
            {
               float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };


          

            Varyings Vertex(const Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                return output;
            }

            half4 Fragment(Varyings input) : SV_TARGET
            {
                float2 normUV = GetNormalizedScreenSpaceUV(input.positionHCS);
                float sceneDepth = SampleSceneDepth(normUV);
                float depthTexture = LinearEyeDepth(sceneDepth, _ZBufferParams);
                float depthObject = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);
                float lerppp = pow(1 - saturate(depthTexture - depthObject), 15);
                float4 newColor = lerp(_Color, _IntersectionColor, lerppp);
                
                return newColor;
                
            }
            ENDHLSL
        }
    }
}
