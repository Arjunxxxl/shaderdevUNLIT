Shader "Custom/surface_1_difused" {

	Properties{
		_MainTexture("main texture", 2D) = "white"{}
		_BumpMap("Normal", 2D) = "bump"{}
		_RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower("Rim Power", Range(0.5,8.0)) = 3.8

		_Detail("Detail Map", 2D) = "grey"{}

		_Cube("CubeMap", CUBE) = ""{}

		_ColorTint("Color Tint", Color) = (1.0, 0.6, 0.6, 1.0)

		_FogColor("Fog color", Color) = (1,1,1,1)
	}

	SubShader{
		Tags{"RenderType"="Opaque"}
		CGPROGRAM

		#pragma target 3.0

		#pragma debug
		#pragma surface surf Lambert finalcolor:myColor vertex:vert

		struct Input 
		{
			float2 uv_MainTexture;
			float2 uv_BumpMap;
			float3 viewDir;
			float2 uv_Detail;

			float3 worldRefl;
			INTERNAL_DATA

			float3 worldPos;

			half fog;
		};

		sampler2D _MainTexture;
		sampler2D _BumpMap;
		float4 _RimColor;
		float _RimPower;
		sampler2D _Detail;

		fixed4 _FogColor;

		float4 _ColorTint;

		samplerCUBE _Cube;


		void vert(inout appdata_full v, out Input data)
		{
			UNITY_INITIALIZE_OUTPUT(Input, data);
			float4 hpos = UnityObjectToClipPos(v.vertex);
			hpos.xy /= hpos.w;
			data.fog = min(1, dot(hpos.xy, hpos.xy)*0.5);
		}

		void myColor(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			//color *= _ColorTint;

			fixed3 fogcolor = _FogColor.rgb;
			#ifdef UNITY_PASS_FORWARDADD
			fogcolor = 0;
			#endif

			color.rgb = lerp(color.rgb, fogcolor, IN.fog);

		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTexture, IN.uv_MainTexture).rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			o.Emission = _RimColor.rgb * pow(rim, _RimPower);

			o.Albedo *= tex2D(_Detail, IN.uv_Detail).rgb *3;

			clip(frac(IN.worldPos.y + IN.worldPos.z*0.1)-0.5);

			//o.Emission += texCUBE(_Cube, IN.worldRefl).rgb/4;
			o.Emission += texCUBE (_Cube, WorldReflectionVector (IN, o.Normal)).rgb/4;
		}

		ENDCG
	}

	//Fallback "Diffuse"

}
