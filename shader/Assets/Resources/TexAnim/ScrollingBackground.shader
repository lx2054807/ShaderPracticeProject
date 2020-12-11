Shader "Unlit/ScrollingBackground"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DetailedTex("DetailedTex", 2D) = "white" {}
        _ScrollX("MainTex Scroll Speed",range(0.1,10)) = 0.3
        _Scroll2X("DetailedTex Scroll Speed", range(0.1,10)) = 0.2
        _Multiplier("Layer Multiplier", range(1,10)) = 1
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
            sampler2D _DetailedTex;
            float4 _DetailedTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.uv, _DetailedTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailedTex, i.uv.zw);

                fixed4 col = lerp(firstLayer, secondLayer, secondLayer.a);
                col.rgb *= _Multiplier;
                return col;
            }
            ENDCG
        }
    }
}
