Shader "Custom/NormalMap"
{
    Properties
    {
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1, 1, 1, 1)

        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Scale", Float) = 1.0

        _Shininess ("Shininess", Range(0.0, 1.0)) = 0.078125

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
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

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
                
                //VertexNormalInputs normalInput = GetVertexNormalInputs(i.normalOS, i.tangentOS);
                //real sign = i.tangentOS.w * GetOddNegativeScale();
                //half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
                //float sgn = tangentWS.w;
                //float3 bitangent = sgn * cross(normalInput.normalWS.xyz, tangentWS.xyz);
                //half3x3 tangentToWorld = half3x3(tangentWS.xyz, bitangent.xyz, normalInput.normalWS.xyz);
                //o.lightDir = mul(tangentToWorld, ObjSpaceLightDir(i.positionOS.xyz));
                //o.viewDir = mul(tangentToWorld, GetObjectSpaceNormalizeViewDir(i.positionOS.xyz));

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

                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _BaseColor;
                half3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv));
                normal.xy *= _BumpScale;
                half3 halfDir = normalize(lightDir + viewDir);
                half3 diff = saturate(dot(normal, lightDir));
                half3 spec = pow(max(0, dot(normal, halfDir)), _Shininess * 128);
                half3 color = baseColor.rgb * diff + spec;
                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}