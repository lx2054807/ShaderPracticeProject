﻿Shader "Unlit/MotionBlurWithDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize("_BlurSize", float) = 1.0
    }
        SubShader
        {
            CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            float4x4 _CurrentViewProjectionInverseMatrix;
            float4x4 _PreviousViewProjectionMatrix;
            half _BlurSize;

            struct v2f 
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                half2 uv_depth : TEXCOORD1;
            };

            v2f vert ( appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv_depth = v.texcoord;

#if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                    o.uv_depth.y = 1 - o.uv_depth.y;
#endif
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                // depth buffer value at this pixel
                float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
                // H is the viewport position at this pixel in the range -1 to 1
                float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
                // Transform by the view-projection inverse
                float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
                // Divide by w to get the world position
                float4 worldPos = D / D.w;

                float4 currentPos = H;
                float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
                previousPos /= previousPos.w;

                float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

                float2 uv = i.uv;
                float4 col = tex2D(_MainTex, uv);
                uv += velocity * _BlurSize;
                for (int it = 1; it < 3; it++) 
                {
                    float4 currentColor = tex2D(_MainTex, uv);
                    col += currentColor;
                }
                col /= 3;
                return fixed4(col.rgb, 1);
            }
            ENDCG

        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            ENDCG
        }
    }
    FallBack Off
}
