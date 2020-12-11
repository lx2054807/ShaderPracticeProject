Shader "Unlit/Fade"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,0,0,1)
        _SubColor("SubColor", Color) = (0,1,1,1)
        _FadeScale("FadeScale", range(0,1)) = 0
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float y : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _MainColor;
            fixed4 _SubColor;
            float _FadeScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.y = v.vertex.y;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float y = i.y;
                float s = y + _FadeScale / 2;
                float f = saturate(s / _FadeScale);
                //fixed4 col = smoothstep(_MainColor, _SubColor, f);
                fixed4 col = lerp(_MainColor, _SubColor, f);
                return col;
            }
            ENDCG
        }
    }
}
