// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/world_normal_shader"
{
	Properties
	{
		_ColorRangee("color range", Range(0, 1)) = 1
	}

	SubShader{
		Pass 
		{
			CGPROGRAM

			#pragma vertex vert_function
			#pragma fragment frag_function

			#include "UnityCG.cginc"


			// get vertices normals color and uvs
			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			float _ColorRangee;


			struct v2f {
				float4 vertex : SV_POSITION;
				half3 worldNormal : TEXCOORD0;
			};

			// build my object
			v2f vert_function (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			//draw the pixel onto the screen
			fixed4 frag_function(v2f IN) : SV_Target
			{
				fixed4 c = 0;
				c.rgb = IN.worldNormal* _ColorRangee + .5;
				return c;
			}

			ENDCG
		}
	}
	
}
