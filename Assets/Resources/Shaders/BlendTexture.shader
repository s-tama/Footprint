Shader "Custom/BlendTexture"
{
    Properties
    {
        [MainTexture] _BaseMap("Texture", 2D) = "white" {}
        _BlendMap("Blend Texture", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1, 1, 1, 1)
        _Ratio("Blend Ratio", Range(0, 1)) = 0.5
        _Position("Blend Position", Vector) = (0, 0, 0, 0)
        _Rotate("Blend Rotate", Range(-360, 360)) = 0
        _Scale("Blend Scale", Range(0, 1)) = 1

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
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

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
                float2 blendUV = uv;
                blendUV = ((blendUV - 0.5) / _Scale) + 0.5;
                blendUV = mul(blendUV - 0.5, rotateMatrix) + 0.5;
                blendUV += _Position.xy;

                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half4 blendColor = SAMPLE_TEXTURE2D(_BlendMap, sampler_BlendMap, blendUV);
                half4 color = lerp(baseColor, blendColor, _Ratio);
                return half4(color.rgb, 1);
            }
            ENDHLSL
        }
    }
}
