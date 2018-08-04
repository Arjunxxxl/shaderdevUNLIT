Shader "Unlit/custom/showUv"
{
	Properties
	{
	}
	SubShader
	{

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION; 
			};

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				return fixed4(IN.uv, 0, 0);
			}

			ENDCG
		}
	}
}
