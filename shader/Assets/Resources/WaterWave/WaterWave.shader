Shader "Unlit/WaterWave"
{
    Properties
    {
        _Color("Color Tint", color) = (0,0.15,0.115,1)
        _MainTex ("Texture", 2D) = "white" {}
        _WaveMap("Bump", 2D) = "bump" {}
        _CubeMap("Cubemap", Cube) = "_Skybox" {}
        _WaveXSpeed("Wave Horizontal Speed", range(-0.2, 0.2))= 0.1
        _WaveYSpeed("Wave Vertical Speed", range(-0.2, 0.2)) = 0.01
        _Distortion("Distortion", range(0,100))=10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        
        GrabPass {"_RefractionTex"}
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
                float3 normal :NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 srcPos : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            sampler2D _WaveMap;
            float4 _WaveMap_ST;
            samplerCUBE _CubeMap;
            float _WaveXSpeed;
            float _WaveYSpeed;
            float _Distortion;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.srcPos = ComputeGrabScreenPos(o.pos);
                
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _WaveMap);
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBiNormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBiNormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBiNormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBiNormal.z, worldNormal.z, worldPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);

                fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
                fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
                fixed3 bump = normalize(bump1 + bump2);

                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.srcPos.xy = offset * i.srcPos.z + i.srcPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.srcPos.xy/i.srcPos.w).rgb;

                bump = normalize(half3(dot(i.TtoW0.xyz, bump),dot(i.TtoW1.xyz, bump),dot(i.TtoW2.xyz, bump)));

                fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
                fixed3 reflDir = reflect(-viewDir, bump);
                fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb * _Color.rgb;

                fixed fresnel = pow(1- saturate(dot(viewDir, bump)),4);
                fixed3 finalColor = reflCol * fresnel + refrCol * (1-fresnel);
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
