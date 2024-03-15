Shader "Custom/Ground"
{
    Properties
    {
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)

        [HideInInspector] _FootprintMap("Footprint Texture", 2D) = "black" {}
        [HideInInspector] _FootprintColor("Footprint Color", Color) = (0, 0, 0, 1)
        _Shininess ("Shininess", Range(0.0, 1.0)) = 0.078125

        [HideInInspector] _FootprintNormalMap("Footprint Normal Texture", 2D) = "bump" {}
        _BumpScale("Scale", Float) = 1.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Pass
        {
            Name "Footprint"
            Tags{ "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            //#pragma target 4.5
            //#pragma only_renderers gles gles3 glcore d3d11
            //#pragma target 2.0

            #pragma vertex VSMain
            #pragma fragment PSMain

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            TEXTURE2D(_FootprintMap);
            SAMPLER(sampler_FootprintMap);
            TEXTURE2D(_FootprintNormalMap);
            SAMPLER(sampler_FootprintNormalMap);
            half4 _FootprintColor;
            half _Shininess;

            float3 ObjSpaceLightDir(float3 positionOS)
            {
                float3 objSpaceLightPos = TransformWorldToObject(_MainLightPosition.xyz);
                return objSpaceLightPos - positionOS;
            }

            float3 ObjSpaceViewDir(float3 positionOS)
            {
                float3 objSpaceCameraPos = TransformWorldToObject(_WorldSpaceCameraPos.xyz);
                return objSpaceCameraPos - positionOS.xyz;
            }

            Varyings VSMain(Attributes i)
            {
                Varyings o = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(i.positionOS.xyz);
                o.positionCS = vertexInput.positionCS;
                o.uv = TRANSFORM_TEX(i.uv, _BaseMap);

                float3 binormal = cross(normalize(i.normalOS), normalize(i.tangentOS.xyz)) * i.tangentOS.w;
                float3x3 rotation = float3x3(i.tangentOS.xyz, binormal, i.normalOS);
                o.lightDir = mul(rotation, ObjSpaceLightDir(i.positionOS.xyz));
                o.viewDir = mul(rotation, ObjSpaceViewDir(i.positionOS.xyz));

                return o;
            }

            half4 PSMain(Varyings i) : SV_Target
            {
                half3 lightDir = normalize(i.lightDir);
                half3 viewDir = normalize(i.viewDir);

                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half4 footprintColor = SAMPLE_TEXTURE2D(_FootprintMap, sampler_FootprintMap, i.uv);

                half3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_FootprintNormalMap, sampler_FootprintNormalMap, i.uv));
                normal.xy *= _BumpScale;
                half3 halfDir = normalize(lightDir + viewDir);
                half3 diff = saturate(dot(normal, lightDir));
                half3 spec = pow(max(0, dot(normal, halfDir)), _Shininess * 128);

                half3 color = lerp(baseColor.rgb, _FootprintColor.rgb, footprintColor.r);
                //color *= diff + spec;

                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}
