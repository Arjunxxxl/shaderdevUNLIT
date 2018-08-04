Shader "Custom/tessalation_without" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DispText ("dist texture", 2D) = "grey"{}
		_NormalMaps ("Normal", 2D) = "bump"{}
		_Displacement("Displacement", Range(0.0, 1.0))= 0.3
		_SpecColor("spec color", Color) = (0.5,0.5,0.5,0.5)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		
		#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp nolightmap
		#pragma target 4.6

		struct appdata{
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};

		sampler2D _DispText;
		float _Displacement;

		void disp(inout appdata v)
		{
			float d = tex2Dlod(_DispText, float4(v.texcoord.xy, 0, 0)).r * _Displacement;
			v.vertex.xyz += v.normal * d;
		}

		struct Input{
			float2 uv_MainTex;
		};

		sampler2D _MainTex;
		sampler2D _NormalMaps;
		float4 _Color;

		void surf(Input IN, inout SurfaceOutput o){
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Specular = 0.3;
			o.Gloss = 1.0;
			o.Normal = UnpackNormal(tex2D(_NormalMaps, IN.uv_MainTex));
		}

		ENDCG
	}
	FallBack "Diffuse"
}
