// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/EnviReflection"
{

	Properties 
	{
		_NormalMap("Normal", 2D) = "bump"{}
		_MainTexture("Main texture", 2D) = "white"{}
		_OcclusionMap("_Occlusion Map", 2D) = "white"{}
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCg.cginc"

			struct v2f{
				float3 worldpos : TEXCOORD0;
				half3 tspace0 : TEXCOORD1;
				half3 tspace1 : TEXCOORD2;
				half3 tspace2 : TEXCOORD3;
				float2 uv : TEXCOORD4;
				float4 pos : SV_POSITION;
			};

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

			sampler2D _NormalMap;
			sampler2D _MainTexture;
			sampler2D _OcclusionMap;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				/*float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldviewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldRefection = reflect(-worldviewDir, worldNormal);*/
				o.worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 wnormal= UnityObjectToWorldNormal(v.normal);
				half3 wtangent= UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSine = v.tangent.w * unity_WorldTransformParams.w;
				half3 wBiTangent = cross(wnormal, wtangent) * tangentSine;

				o.tspace0 = half3(wtangent.x, wBiTangent.x, wnormal.x);
				o.tspace0 = half3(wtangent.y, wBiTangent.y, wnormal.y);
				o.tspace0 = half3(wtangent.z, wBiTangent.z, wnormal.z);

				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{	
				half3 tnormal = UnpackNormal(tex2D(_NormalMap, i.uv));
				half3 worldnormal;
				worldnormal.x = dot(i.tspace0, tnormal);
				worldnormal.y = dot(i.tspace1, tnormal);
				worldnormal.z = dot(i.tspace2, tnormal);

				half3 worldviewDir = normalize(UnityWorldSpaceViewDir(i.worldpos));
				half3 worldReflection = reflect(-worldviewDir, worldnormal);
				half4 skydata = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldReflection);
				half3 skyColor = DecodeHDR(skydata, unity_SpecCube0_HDR);

				fixed4 c = 0;
				c.rgb = skyColor;

				fixed3 mainColor = tex2D(_MainTexture, i.uv).rgb;
				fixed occlusion = tex2D(_OcclusionMap, i.uv).r;
				c.rgb *= mainColor;
				c.rgb *= occlusion;

				return c;
			}


			ENDCG
		}
	}
}
