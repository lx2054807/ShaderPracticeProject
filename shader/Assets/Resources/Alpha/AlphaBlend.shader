Shader "Unlit/AlphaBlend"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _AlphaScale("AlphaScale", Range(0,1)) = 1
            [HDR]
            _Color("Color", color) = (1,1,1,1)
    }
        SubShader
        {
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}// transparent = 3000 透明物体
            LOD 100
            ZWrite Off  // 关闭深度写入
            Blend  SrcAlpha OneMinusSrcAlpha // 混合方程

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
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                half _AlphaScale;
                fixed4 _Color;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // sample the texture
                    fixed4 col = tex2D(_MainTex, i.uv);
                    col.a *= _AlphaScale;
                    col.rgb *= _Color;
                    return col;
                }
                ENDCG
            }
        }
}
