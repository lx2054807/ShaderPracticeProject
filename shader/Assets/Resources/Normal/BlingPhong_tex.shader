Shader "Unlit/BlingPhong_tex"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", range(0,2)) = 1
        _MainTex("MainTex", 2D) = "white" {}

    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "BlingPhong_tex"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            half _Gloss;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 normal : TexCoord0;
                fixed3 lightdir : TexCoord1;
                fixed3 worldpos : TexCoord2;
                fixed2 uv : TexCoord3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 Normal = UnityObjectToWorldNormal(v.normal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                o.normal = Normal;
                o.lightdir = lightDir;
                o.worldpos = worldPos;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * max(0, dot(i.normal, i.lightdir));

                fixed3 view = normalize(UnityWorldSpaceViewDir(i.worldpos));
                fixed3 halfDir = normalize(view + i.lightdir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.normal, halfDir)), 1 / _Gloss);

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
