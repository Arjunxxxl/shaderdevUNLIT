Shader "Unlit/unlit_diffulsed"
{
	Properties
	{
		[NoScaleOffSet] _MainTexture("main texture", 2D) = "white"{}
		_Color("main color", color) = (1,1,1,1)
	}
	SubShader
	{
		
		Pass
		{

			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "Lighting.cginc"

			#pragma multi_compile_fwbase nolightmap nodirlightmap nodynlightmap novertexlightmap
			#include "AutoLight.cginc"
			// make fog work
			#pragma multi_compile_fog
			

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				SHADOW_COORDS(1) // put shadows data into TEXCOORD1
				float4 vertex : SV_POSITION;
				fixed3 diff : COLOR0; //diffused light color
				fixed3 ambient : COLOR1;
				UNITY_FOG_COORDS(1)
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				half3 worldnormal = UnityObjectToWorldNormal(v.normal);
				half nl = max(0, dot(worldnormal, _WorldSpaceLightPos0.xyz));
				o.diff = nl * _LightColor0.rgb;
				o.ambient = ShadeSH9(half4(worldnormal,1)); //ambient light data
				TRANSFER_SHADOW(o);

				UNITY_TRANSFER_FOG(o,o.vertex);

				return o;
			}

			sampler2D _MainTexture;
			float4 _Color;
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTexture, i.uv);
				fixed shadow = SHADOW_ATTENUATION(i);// 1 = lit 0 = full dark
				fixed3 lighting = i.diff * shadow +i.ambient;
				//col *= i.diff;
				col.rgb *= lighting;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}
			ENDCG
		}

		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

		//shadow pass
		pass{
			Tags{"LightMode"="ShadowCaster"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			

			struct v2f{
				V2F_SHADOW_CASTER;
				
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);

				return o;
			}

			float4 frag(v2f i) :SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i);
			}

			ENDCG
		}

	}
}
