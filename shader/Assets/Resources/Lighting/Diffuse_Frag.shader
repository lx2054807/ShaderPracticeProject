Shader "Unlit/Diffuse_Frag"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "Diffuse_Frag"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
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
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 Normal = UnityObjectToWorldNormal(v.normal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(mul(unity_ObjectToWorld, v.vertex).xyz));
                o.normal = Normal;
                o.lightdir = lightDir;
                return o;
            }

            // 计算放在片元着色器中, 效果更好
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(i.normal, i.lightdir));
                fixed4 color = fixed4(ambient + diffuse, 1);
                return color;
            }
            ENDCG
        }
    }
}
