Shader "Unlit/DeferredPost"
{
    // 需要在UNITY Graphics里替换默认Deferred Post Shader
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Zwrite off
            Blend [_SrcBlend][_DstBlend] // LDR DstColor zero HDR one one
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_lightpass
        //代表排除不支持MRT的硬件
            #pragma exclude_renderers norm
            #pragma multi_compile __ UNITY_HDR_ON

            #include "UnityCG.cginc"
            #include "UnityGBuffer.cginc"
            #include "UnityDeferredLibrary.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _CameraGBufferTexture0; 
            sampler2D _CameraGBufferTexture1;
            sampler2D _CameraGBufferTexture2;

            unity_v2f_deferred vert (appdata v)
            {
                unity_v2f_deferred o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeScreenPos(o.pos);
                o.ray = UnityObjectToViewPos(v.vertex) * float3(-1, -1, 1);
                o.ray = lerp(o.ray, v.normal, _LightAsQuad);
                return o;
            }

#ifdef UNITY_HDR_ON
            half4
#else
            fixed4
#endif
                frag(unity_v2f_deferred i) : SV_Target
            {
                float3 worldPos;
                float2 uv;
                half3 lightDir;
                float atten;
                float fadeDist;
                UnityDeferredCalculateLightParams(i, worldPos, uv, lightDir, atten, fadeDist);  
                half3 lightColor = _LightColor.rgb * atten;
                half4 gbuffer0 = tex2D(_CameraGBufferTexture0, uv);
                half4 gbuffer1 = tex2D(_CameraGBufferTexture1, uv);
                half4 gbuffer2 = tex2D(_CameraGBufferTexture2, uv);
                half3 diffuseColor = gbuffer0.rgb;
                half3 specularColor = gbuffer1.rgb;
                float gloss = gbuffer1.a * 20;
                float3 worldNormal = normalize(gbuffer2.xyz * 2 - 1);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                fixed3 halfDir = normalize(lightDir + viewDir);
                half3 diffuse = lightColor * diffuseColor * max(0, dot(worldNormal, lightDir));
                half3 specular = lightColor * specularColor * pow(max(0, dot(worldNormal, halfDir)), gloss);
                fixed4 color = float4(diffuse + specular, 1);
#ifdef UNITY_HDR_ON
                return color;
#else
                return exp2(-color);
#endif
                }
                ENDCG
            }

        //LDR转码
        Pass
        {
            Zwrite off
            Cull off
            Stencil
            {
                ref[_StencilNonBackground]
                readMask[_StencilNonBackground]
                compback equal
                compfront equal
            }
            CGPROGRAM
           #pragma target 3.0
                #pragma vertex vert
                #pragma fragment frag
                    //代表排除不支持MRT的硬件
                    #pragma exclude_renderers norm


            sampler2D _LightBuffer;
            struct v2f 
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert(float4 vertex:POSITION, float2 texcoord : TEXCOORD0) 
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(vertex);
                o.texcoord = texcoord.xy;
    #ifdef UNITY_SINGLE_PASS_STEREO
                o.texcoord = TransformStereoScreenSpaceTex(o.texcoord, 1.0);
    #endif
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                return -log2(tex2D(_LightBuffer, i.texcoord));
            }
            ENDCG
        }
    }
}
