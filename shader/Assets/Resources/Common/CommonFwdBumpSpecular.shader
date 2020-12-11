Shader "Unlit/CommonFwdBumpSpecular"
{
    Properties
    {
        _Color("_Color", color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _SpecularColor("SpecularColor", color) = (1,1,1,1)
        _Gloss("Gloss", range(8,256)) = 20
        _BumpTex("BumpTex",2D) = "white" {}
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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 reg1 : TEXCOORD1;
                float4 reg2 : TEXCOORD2;
                float4 reg3 : TEXCOORD4;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _SpecularColor;
            float _Gloss;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpTex);

                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 binormal = cross(normal, tangent) * v.tangent.w;

                o.reg1 = float4(tangent.x, binormal.x, normal.x, worldPos.x);
                o.reg2 = float4(tangent.y, binormal.y, normal.y, worldPos.y);
                o.reg3 = float4(tangent.z, binormal.z, normal.z, worldPos.z);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 worldPos = float3(i.reg1.w, i.reg2.w, i.reg3.w);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 halfDir = normalize(lightDir + viewDir);

                float3 bump = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
                bump = normalize(float3(dot(i.reg1.xyz, bump), dot(i.reg2.xyz, bump), dot(i.reg3.xyz, bump)));

                fixed3 diffuse = albedo * _LightColor0 * saturate(dot(bump, lightDir));
                fixed3 specular = _LightColor0 * pow(saturate(dot(bump, halfDir)), _Gloss);
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 reg1 : TEXCOORD1;
                float4 reg2 : TEXCOORD2;
                float4 reg3 : TEXCOORD4;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _SpecularColor;
            float _Gloss;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpTex);

                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 binormal = cross(normal, tangent) * v.tangent.w;

                o.reg1 = float4(tangent.x, binormal.x, normal.x, worldPos.x);
                o.reg2 = float4(tangent.y, binormal.y, normal.y, worldPos.y);
                o.reg3 = float4(tangent.z, binormal.z, normal.z, worldPos.z);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 worldPos = float3(i.reg1.w, i.reg2.w, i.reg3.w);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 halfDir = normalize(lightDir + viewDir);

                float3 bump = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
                bump = normalize(float3(dot(i.reg1.xyz, bump), dot(i.reg2.xyz, bump), dot(i.reg3.xyz, bump)));

                fixed3 diffuse = albedo * _LightColor0 * saturate(dot(bump, lightDir));
                fixed3 specular = _LightColor0 * pow(saturate(dot(bump, halfDir)), _Gloss);
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

                return fixed4(ambient + (diffuse + specular) * atten, 1);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
