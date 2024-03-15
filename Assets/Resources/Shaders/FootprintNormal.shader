Shader "Custom/FootprintNormal"
{
    Properties
    {
        [HideInInspector] [MainTexture] _BaseMap("Texture", 2D) = "white" {}
        [HideInInspector] _BlendMap("Blend Texture", 2D) = "white" {}
        [HideInInspector] [MainColor] _BaseColor("Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Ratio("Blend Ratio", Range(0, 1)) = 0.5
        [HideInInspector] _Position("Blend Position", Vector) = (0, 0, 0, 0)
        [HideInInspector] _Rotate("Blend Rotate", Range(-360, 360)) = 0
        [HideInInspector] _Scale("Blend Scale", Range(0, 1)) = 1
        [HideInInspector] _MainMap("Footprint Main Texture", 2D) = "white" {}

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (0.5, 0.5, 0.5, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
            "ShaderModel" = "4.5"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            //#pragma target 4.5

            #pragma vertex VSMain
            #pragma fragment PSMain

            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"

            #define PI (3.14159265359)
            #define DEG2RAD (PI / 180)

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BlendMap);
            SAMPLER(sampler_BlendMap);
            TEXTURE2D(_MainMap);
            SAMPLER(sampler_MainMap);
            half _Ratio;
            half3 _Position;
            half _Rotate;
            half _Scale;

            Varyings VSMain(Attributes i)
            {
                Varyings o = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(i.positionOS.xyz);
                o.positionCS = vertexInput.positionCS;
                o.uv = TRANSFORM_TEX(i.uv, _BaseMap);
                return o;
            }

            half4 PSMain(Varyings i) : SV_Target
            {
                // âÒì]çsóÒ
                half rad = _Rotate * DEG2RAD;
                float2x2 rotateMatrix = float2x2
                (
                    cos(rad), -sin(rad),
                    sin(rad), cos(rad)
                );

                float2 uv = i.uv;
                float2 blendUV = uv - _Position;
                blendUV = blendUV / _Scale;
                blendUV = mul(blendUV, rotateMatrix);
                blendUV += 0.5;

                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half4 blendColor = SAMPLE_TEXTURE2D(_BlendMap, sampler_BlendMap, blendUV);
                half4 mainColor = SAMPLE_TEXTURE2D(_MainMap, sampler_MainMap, i.uv);
                half3 color = lerp(baseColor.rgb, blendColor.rgb, mainColor.r);
                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}
