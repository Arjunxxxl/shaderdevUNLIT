// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/custom1"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)
		_Extrude ("Extrude amt", float) = 1
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
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			float4 _Color;
			sampler2D _MainTex;
			float _Extrude;

			struct v2f {
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			// build my object
			v2f vert_function (appdata v)
			{
				v2f o;
				//v.vertex.xyz += v.normal.xyz*_Extrude * sin(_Time.y);
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = v.uv;
				return o;
			}

			//draw the pixel onto the screen
			fixed4 frag_function(v2f IN) : SV_Target
			{
				fixed4 texColor = tex2D(_MainTex, IN.uv);
				return texColor * _Color;
			}

			ENDCG
		}

	}
	
}
