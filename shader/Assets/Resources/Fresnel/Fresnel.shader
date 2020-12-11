Shader "Unlit/Fresnel"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _CubeMap("CubeMap", Cube) = "_Skybox" {}
        _FresnelScale("FresnelScale", range(0,1)) = 1   //菲涅尔程度
        _FresnelInten("FresnelInten", range(1,5)) = 5   //菲涅尔强度
        _RefractRate("RefractRate", range(0,1)) = 0.5   //折射率
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldRefl : TEXCOORD1;
                float3 worldRefr : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                float3 worldViewDir : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _CubeMap;
            half _FresnelScale;
            half _FresnelInten;
            half _RefractRate;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);  //计算反射
                //o.worldRefr = refract(normalize(-o.worldViewDir), normalize(o.worldNormal), _RefractRate);  //计算折射
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 reflection = texCUBE(_CubeMap, i.worldRefl).rgb;
                //fixed3 refraction = texCUBE(_CubeMap, i.worldRefr).rgb;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(normalize(i.worldNormal), normalize(i.worldViewDir)), _FresnelInten); //菲涅尔公式 F + (1-F) * pow(1-normal点乘viewdir, I)

                //float3 re = lerp(reflection, refraction, fresnel);  // 反射与折射插值
                float3 re = reflection;
                col.rgb = lerp(col.rgb, re, saturate(fresnel));   // 颜色插值
                return col;
            }
            ENDCG
        }
    }
}
