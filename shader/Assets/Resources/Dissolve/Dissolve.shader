Shader "Unlit/Dissolve"
{
    Properties
    {
        _BurnAmount("BurnAmount", range(0.0,1.0)) = 0.0
        _LineWidth("LineWidth", range(0.0,0.2)) = 0.1
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal map",2D) = "white" {}
        _BurnFirstColor("BurnFirstColor",color) = (1,1,0,1)
        _BurnSecondColor("BrunSecondColor",color) = (0,1,0,1)
        _BurnMap("BurnMap",2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpTex : TEXCOORD1;
                float2 uvBurnTex : TEXCOORD2;
                float3 lightDir : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                float4 pos : SV_POSITION;
                SHADOW_COORDS(5)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _LineWidth;
            float _BurnAmount;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;
            fixed4 _BurnFirstColor;
            fixed4 _BurnSecondColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvBumpTex = TRANSFORM_TEX(v.uv, _BumpMap);
                o.uvBurnTex = TRANSFORM_TEX(v.uv, _BurnMap);

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurnTex).rgb;
                clip (burn.r - _BurnAmount);

                float3 tangetLightDir = normalize(i.lightDir);
                float3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uvBumpTex));

                fixed3 albedo = tex2D(_MainTex, i.uvMainTex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = unity_LightColor0.rgb * albedo * max(0,dot(tangentNormal, tangetLightDir));

                fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);
                fixed3 burnColor = lerp(_BurnFirstColor,_BurnSecondColor,t);

                burnColor = pow(burnColor,5);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor, t * step(0.0001,_BurnAmount));
                return fixed4(finalColor,1);
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include <UnityCG.cginc>

            float _BurnAmount;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {    
                V2F_SHADOW_CASTER;
                float2 uvBurnMap : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER(o);
                o.uvBurnMap = TRANSFORM_TEX(v.vertex, _BurnMap);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                clip(burn.r - _BurnAmount);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}