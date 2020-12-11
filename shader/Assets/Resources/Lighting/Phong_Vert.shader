Shader "Unlit/Phong_Vert"
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
            Name "Phong_Vert"
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
                fixed3 color : Color;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 Normal = UnityObjectToWorldNormal(v.normal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(Normal, lightDir));

                fixed3 reflectDir = normalize(reflect(-lightDir, Normal));  // 反射光计算
                fixed3 view = normalize(UnityWorldSpaceViewDir(worldPos));  // 视线计算
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate( dot(view, reflectDir)), _Gloss); // Phong模型下高光计算: 与视线与反射光点乘的N(高光系数)次方成正比
                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }
}
