Shader "Unlit/Deferred"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Diffuse", color) = (1,1,1,1)
        _Specular("Specular", color) = (1,1,1,1)
        _Gloss("Gloss", range(0,20)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "Deferred"}
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            //代表排除不支持MRT的硬件 Multiple Render Target
            #pragma exclude_renderers norm
            #pragma multi_compile __ UNITY_HDR_ON   //HDR


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
            };

            struct DeferredOutput 
            {
                float4 gBuffer0 : SV_TARGET0; //DIFFUSE
                float4 gBuffer1 : SV_TARGET1; //SPECULAR, GLOSS
                float4 gBuffer2 : SV_TARGET2; //NORMAL
                float4 gBuffer3 : SV_TARGET3; //EMISSION...
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            half _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            DeferredOutput frag (v2f i)
            {
                DeferredOutput o;
                fixed3 color = tex2D(_MainTex, i.uv).rgb * _Diffuse.rgb;
                o.gBuffer0.rgb = color;
                o.gBuffer0.a = 1;
                o.gBuffer1.rgb = _Specular.rgb;
                o.gBuffer1.a = _Gloss / 20;
                o.gBuffer2 = float4(i.worldNormal * 0.5 + 0.5, 1);
#if !defined(UNITY_HDR_ON)
                color.rgb = exp2(-color.rgb);
#endif
                o.gBuffer3 = fixed4(color, 1);
                return o;
            }
            ENDCG
        }
    }
}
