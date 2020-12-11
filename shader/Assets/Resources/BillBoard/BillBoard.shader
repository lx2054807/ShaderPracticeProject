// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/BillBoard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        _VerticalRestraints("VerticalRestraints", range(0,1)) = 1 //约束垂直方向程度, 为0时固定了向上的方向, 为1时固定了法线方向
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "DisableBatching" = "True"}
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

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
            fixed4 _Color;
            float _VerticalRestraints;

            v2f vert (appdata v)
            {
                float3 center = float3(0, 0, 0);
                //fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                //float3 viewer = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 viewer = (mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)));

                float3 normalDir = viewer - center;
                normalDir.y = normalDir.y * _VerticalRestraints;
                normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));

                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                v2f o;
                o.vertex = UnityObjectToClipPos(localPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
