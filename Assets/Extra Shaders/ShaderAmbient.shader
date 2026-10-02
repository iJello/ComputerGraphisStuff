
Shader "Custom/ShaderAmbient"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Base Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalRenderPipeline"
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
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
            CBUFFER_END

            // Vertex Shader
            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // Transform position to clip space
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                // Transform normal to world space
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

                // Pass UV coordinates
                OUT.uv = IN.uv;

                return OUT;
            }

            // Fragment Shader
            half4 frag(Varyings IN) : SV_Target
            {
                // Sample the base texture
                half4 texColor = SAMPLE_TEXTURE2D(
                    _MainTex,
                    sampler_MainTex,
                    IN.uv
                );

                // Fetch the main light
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);

                // Normalize world-space normal
                half3 normalWS = normalize(IN.normalWS);

                // Calculate Lambertian diffuse lighting
                half NdotL = saturate(dot(normalWS, lightDir));

                // Calculate ambient lighting using spherical harmonics
                half3 ambientSH = SampleSH(normalWS);

                // Combine base color, texture, and direct diffuse lighting
                half3 diffuse = texColor.rgb * _BaseColor.rgb * NdotL;

                // Combine diffuse and ambient lighting
                half3 finalColor = diffuse + ambientSH * texColor.rgb * _BaseColor.rgb;

                // Return final color
                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }
}