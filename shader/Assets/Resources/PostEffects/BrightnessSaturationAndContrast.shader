Shader "Unlit/BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness", float) = 0.0
        _Saturation("Saturation", float) = 0.0
        _Contrast("Contrast",float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
            ZTest Always
            Cull Off
            ZWrite Off

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
            float _Brightness;
            float _Saturation;
            float _Contrast;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                fixed3 finalCol = col.rgb * _Brightness;

                fixed luminance = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
                fixed3 luminanceCol = fixed3(luminance, luminance, luminance);
                finalCol = lerp(luminanceCol, finalCol, _Saturation);

                fixed3 avgCol = fixed3(0.5, 0.5, 0.5);
                finalCol = lerp(avgCol, finalCol, _Contrast);

                return fixed4(finalCol, col.a);
            }
            ENDCG
        }
    }
    Fallback Off
}
