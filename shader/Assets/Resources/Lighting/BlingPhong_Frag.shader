Shader "Unlit/BlingPhong_Frag"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", range(8.0,256)) = 10

    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "BlingPhong_Frag"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            half _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 normal : TexCoord0;
                fixed3 lightdir : TexCoord1;
                fixed3 worldpos : TexCoord2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
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
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(i.normal, i.lightdir));

                fixed3 view = normalize(UnityWorldSpaceViewDir(i.worldpos));
                fixed3 halfDir = normalize(view + i.lightdir);  // 半角计算: 光源与视线的中间位置向量 (v + l)/|v + l|
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.normal, halfDir)), _Gloss);   //BlingPhong模型: 高光与半角和法线的点乘的N次方成正比

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
