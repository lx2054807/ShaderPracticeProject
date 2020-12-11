Shader "Unlit/Reflection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CubeMap("CubeMap", Cube) = "_Skybox" {}
        _Reflect("Reflect", range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float3 worldRef : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _CubeMap;
            half _Reflect;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldViewDir = UnityWorldSpaceViewDir(worldPos);
                o.worldRef = reflect(-worldViewDir, worldNormal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 reflection = texCUBE(_CubeMap, i.worldRef).rgb;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = lerp(col.rgb, reflection, _Reflect);
                return col;
            }
            ENDCG
        }
    }
}
