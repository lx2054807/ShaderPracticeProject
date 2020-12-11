Shader "Unlit/AlphaTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CutOff("CutOff", Range(0,1)) = 0.5     // 裁剪程度
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutOut" "Queue" = "AlphaTest-1" "IgnoreProjector" = "True"}//alphatest = 2450   //需要替换tags 
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _CutOff;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - _CutOff);  // discard frag whose alpha < _CutOff
                clip(i.worldPos.y - 0); // discard frag whose worldpos.y < 0
                return col;
            }
            ENDCG
        }
    }
}
