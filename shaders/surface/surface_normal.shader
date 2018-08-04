Shader "Custom/surface_normal" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		
		#pragma surface surf Lambert vertex:vert

		struct Input{
			float2 uv_MainTex;
			float3 CustomColor;
		};

		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o)
			o.CustomColor = abs(v.normal);
		}

		sampler2D _MainTex;

		void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Albedo *= IN.CustomColor;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
