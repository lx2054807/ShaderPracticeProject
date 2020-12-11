Shader "Unlit/CommonFwdSpecular"
{
    Properties
    {
        _Color("_Color", color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _SpecularColor("SpecularColor", color) = (1,1,1,1)
        _Gloss("Gloss", range(8,256)) = 20
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
                float3 worldPos : TEXCOORD4;
                float3 viewDir : TEXCOORD5;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _SpecularColor;
            float _Gloss;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
                o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 normal = i.normal;
                float3 lightDir = normalize(i.lightDir);
                float3 viewDir = normalize(i.viewDir);
                float3 halfDir = normalize(lightDir + viewDir);

                fixed3 diffuse = albedo * _LightColor0 * saturate(dot(normal, lightDir));
                fixed3 specular = _LightColor0 * _SpecularColor.rgb * pow(saturate(dot(normal, halfDir)), _Gloss);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient + (diffuse + specular) * atten, 1);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd"}
            CGPROGRAM
            #pragma multi_compile_fwdbadd
                //#pragma multi_compile_fwdadd_fullshadows
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"
                #include "Lighting.cginc"
                #include "AutoLight.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 pos : SV_POSITION;
                    float3 normal : TEXCOORD1;
                    float3 lightDir : TEXCOORD2;
                    float3 worldPos : TEXCOORD4;
                    float3 viewDir : TEXCOORD5;
                    SHADOW_COORDS(3)
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                fixed4 _Color;
                fixed4 _SpecularColor;
                float _Gloss;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.normal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
                    o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
                    TRANSFER_SHADOW(o);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // sample the texture
                    fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                    float3 normal = i.normal;
                    float3 lightDir = normalize(i.lightDir);
                    float3 viewDir = normalize(i.viewDir);
                    float3 halfDir = normalize(lightDir + viewDir);

                    fixed3 diffuse = albedo * _LightColor0 * saturate(dot(normal, lightDir));
                    fixed3 specular = _LightColor0 * _SpecularColor.rgb * pow((1 - saturate(dot(normal, halfDir))), _Gloss);
                    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                    return fixed4(ambient + (diffuse + specular) * atten, 1);
                }
                ENDCG
            }
    }
    FallBack "Specular"
}
