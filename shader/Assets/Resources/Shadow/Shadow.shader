Shader "Unlit/Shadow"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8,256)) = 10
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			half _Gloss;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldLight : TEXCOORD1;
				fixed3 worldPos : TEXCOORD2;
				float3 vertexLight:TEXCOORD3;
				SHADOW_COORDS(4)	//结构体中加入阴影
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
#ifdef LIGHTMAP_OFF
				float3 shLight = ShadeSH9(float4(v.normal, 1.0));
				o.vertexLight = shLight;
#ifdef VERTEXLIGHT_ON
				float3 vertexLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
					unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
					unity_4LightAtten0, o.worldPos, o.worldNormal);
				o.vertexLight += vertexLight;
#endif
#endif
				TRANSFER_SHADOW(o);	// 计算阴影
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(i.worldNormal, i.worldLight));

				//高光反射
				fixed3 reflectDir = normalize(reflect(-i.worldLight, i.worldNormal));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), 1 / _Gloss);

				//仅仅计算阴影
				//fixed shadow = SHADOW_ATTENUATION(i);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4(ambient + (diffuse + specular) * atten + i.vertexLight,1);
			}
			ENDCG
		}

		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma multi_compile_fwdadd_fullshadows
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			half _Gloss;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldLight : TEXCOORD1;
				fixed3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(i.worldNormal, i.worldLight));

				//高光反射
				fixed3 reflectDir = normalize(reflect(-i.worldLight, i.worldNormal));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), 1 / _Gloss);
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				return fixed4(ambient + (diffuse + specular) * atten,1);
			}
			ENDCG
		}

				// 使用自带SHADER中的阴影投射
				UsePass "Legacy Shaders/VertexLit/ShadowCaster"

				//Pass
				//{

				//	Tags { "LightMode" = "ShadowCaster" }

				//	CGPROGRAM
				//	#pragma vertex vert
				//	#pragma fragment frag
				//	#pragma target 2.0
				//	#pragma multi_compile_shadowcaster
				//	#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
				//	#include "UnityCG.cginc"

				//	struct v2f {
				//		V2F_SHADOW_CASTER;
				//		UNITY_VERTEX_OUTPUT_STEREO
				//	};

				//	v2f vert(appdata_base v)
				//	{
				//		v2f o;
				//		UNITY_SETUP_INSTANCE_ID(v);
				//		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				//		TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				//		return o;
				//	}

				//	float4 frag(v2f i) : SV_Target
				//	{
				//		SHADOW_CASTER_FRAGMENT(i)
				//	}
				//	ENDCG

				//}
	}


		FallBack "Diffuse"
}
