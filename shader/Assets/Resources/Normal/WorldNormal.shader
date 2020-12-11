Shader "Unlit/WorldNormal"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump" {}  // 法线贴图 又叫凹凸贴图
        _BumpScale("NormalScale", range(0,1)) = 0.5   //法线强度
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", range(8,256)) = 10 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "WorldNormal"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 tc0 : TEXCOORD1;
                float4 tc1 : TEXCOORD2;
                float4 tc2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            half _BumpScale;
            fixed4 _Diffuse;
            fixed4 _Specular;
            half _Gloss;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);             // 取到世界空间下切线T轴
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;  // 计算世界空间下B轴
                o.tc0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x); // 传入TBN以及世界空间位置
                o.tc1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.tc2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.tc0.w, i.tc1.w, i.tc2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tanNormal = UnpackNormal(packedNormal);
                tanNormal.xy *= _BumpScale;
                float3 worldNormal = normalize(float3(dot(i.tc0.xyz, tanNormal), dot(i.tc1.xyz, tanNormal), dot(i.tc2.xyz, tanNormal)));    //计算世界坐标下的法线

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * max(0, dot(worldNormal, lightDir));
                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
