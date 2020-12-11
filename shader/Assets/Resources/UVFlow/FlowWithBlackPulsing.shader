Shader "Unlit/FlowWithBlackPulsing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _FlowMap("FlowMap(RG, A NOISE)", 2D) = "white" {}
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
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _FlowMap;
            float4 _FlowMap_ST;

            float3 flowUVW(float2 uv, float2 flowVector, float time)
            {
                float progress = frac(time);
                float3 uvw;
                uvw.xy = uv + flowVector * progress;
                uvw.z = 1 - abs(1 - 2 * progress);
                return uvw;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _FlowMap);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                float2 flowVector = tex2D(_FlowMap, i.uv.zw).rg;
                float noise = tex2D(_FlowMap, i.uv.zw).a;
                float time = _Time.y + noise;
                float3 uvw;
                uvw = flowUVW(i.uv.xy, flowVector, time);
                fixed4 col = tex2D(_MainTex, uvw.xy) * uvw.z;
                return col;
            }
            ENDCG
        }
    }
}
