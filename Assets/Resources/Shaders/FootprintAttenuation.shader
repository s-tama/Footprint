Shader "Custom/FootprintAttenuation"
{
    Properties
    {
        [HideInInspector] [MainTexture] _BaseMap("Texture", 2D) = "white" {}
        [HideInInspector] [MainColor] _BaseColor("Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Amount("Amount", Float) = 0.01

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (0.5, 0.5, 0.5, 1)
    }
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            //#pragma target 4.5

            #pragma vertex VSMain
            #pragma fragment PSMain

            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"

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

            float _Amount;

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
                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                baseColor.rgb = max(0, baseColor.r - _Amount);
                return baseColor;
            }
            ENDHLSL
        }
    }
}
