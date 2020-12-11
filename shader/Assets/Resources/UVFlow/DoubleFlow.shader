Shader "Unlit/DoubleFlow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _FlowMap("FlowMap(RG, A NOISE)", 2D) = "white" {}
        _UJump("U Jump Per Phase", range(-0.5, 0.5)) = 0.1
        _VJump("V Jump Per Phase", range(-0.5, 0.5)) = 0.1
        _Tiling("Tiling", float) = 1
        _Speed("Speed", range(-1, 2)) = 1
        _Strength("Strength", range(0, 3)) = 1
        _FlowOffset("FlowOffset", range(-1,1)) = 0
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
            float _UJump;
            float _VJump;
            float _Tiling;
            float _Speed;
            float _Strength;
            float _FlowOffset;

            float3 flowUVW(float2 uv, float2 flowVector, float offset, float2 jump, float tiling, float time, bool flowB)
            {
                float phaseOffset = flowB ? 0.5 : 0;
                float progress = frac(time + phaseOffset);
                float3 uvw;
                uvw.xy = uv + flowVector * (progress+ offset);
                uvw.xy *= tiling;
                uvw.xy += phaseOffset;
                uvw.xy += (time - progress) * jump;
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
                flowVector *= _Strength;
                float noise = tex2D(_FlowMap, i.uv.zw).a;
                float time = _Speed * _Time.y + noise;

                float2 jump = (_UJump, _VJump);
                float3 uvw1 = flowUVW(i.uv.xy, flowVector, _FlowOffset, jump, _Tiling, time, false);
                float3 uvw2 = flowUVW(i.uv.xy, flowVector, _FlowOffset, jump, _Tiling, time, true);

                fixed4 col1 = tex2D(_MainTex, uvw1.xy) * uvw1.z;
                fixed4 col2 = tex2D(_MainTex, uvw2.xy) * uvw2.z;

                return col1+col2;
            }
            ENDCG
        }
    }
}
