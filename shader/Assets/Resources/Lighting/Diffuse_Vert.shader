Shader "Unlit/Diffuse_Vert"
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
            Name "Diffuse_Vert"
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
                fixed3 color : Color;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  //模型空间转到裁剪空间
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;  //环境光计算
                fixed3 Normal = UnityObjectToWorldNormal(v.normal); //模型空间转到世界空间 法线
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(mul(unity_ObjectToWorld, v.vertex).xyz));   //光源方向
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(Normal, lightDir));   //漫反射计算,反射光源强度与法线与光源间夹角的余弦成正比 (法线点乘光源) 
                o.color = ambient + diffuse;
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
