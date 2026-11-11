
Shader "Custom/Lampert"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
        }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _MainTex_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.normalWS = normalize(
                    TransformObjectToWorldNormal(IN.normalOS)
                );

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Sample texture
                half4 texColor = SAMPLE_TEXTURE2D(
                    _MainTex,
                    sampler_MainTex,
                    IN.uv
                );

                // Apply base color
                half3 finalColor = texColor.rgb * _BaseColor.rgb;

                // Calculate Lambertian lighting
                half3 normal = normalize(IN.normalWS);
                Light mainLight = GetMainLight();

                half3 lightDir = normalize(mainLight.direction);
                half NdotL = saturate(dot(normal, lightDir));

                // Apply light color and intensity
                half3 diffuse = finalColor * mainLight.color * NdotL;

                return half4(diffuse, 1.0);
            }

            ENDHLSL
        }
    }
}