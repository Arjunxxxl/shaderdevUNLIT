Shader "Custom/surface_lighting" {
	Properties {
		_MainTexture("main texture", 2D) = "white" {}
		_Ramp("ramp texture", 2D) = "white" {}

		_Grain("Light Tome map grains", float) = 1
		_Knee("Light Tome map knees", float) = 0.5
		_Compress("Light Tome map compression", float) = 0.33
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		
		#pragma surface surf StandardDefaultGI

		#include "UnityPBSLighting.cginc"

		//custon light model
		half4 LightingcustomLight(SurfaceOutput s, half3 dirLight, half att)
		{
			half nDot = dot(s.Normal, dirLight);
			half4 c;
			c.rgb = s.Albedo  * _LightColor0.rgb * (att * nDot);
			c.a = s.Alpha;
			return c;
		}

		// custom light wrap model
		half4 LightingWrapLambert(SurfaceOutput s, half3 dirLight, half att)
		{
			half nDot = dot(s.Normal, dirLight);
			half diff = nDot * 0.5 + 0.5;
			half4 c;
			c.rgb = s.Albedo  * _LightColor0.rgb * (att * diff);
			c.a = s.Alpha;
			return c;
		}

		// custom toon effect
		sampler2D _Ramp;

		half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) {
        	half NdotL = dot (s.Normal, lightDir);
        	half diff = NdotL * 0.5 + 0.5;
        	half3 ramp = tex2D (_Ramp, float2(diff, diff)).rgb;
        	half4 c;
        	c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten;
        	c.a = s.Alpha;
        return c;
   		 }	

		// custom spectular effect

		half4 Lightingcustom_spect(SurfaceOutput s, half3 lightDir, half3 viewDir, half att)
		{
			half3 h = normalize(lightDir + viewDir);
			half diff = max(0, dot(s.Normal, lightDir));
			float nh = max(0, dot(s.Normal, h));
			float spect = pow(nh, 48.0);

			half4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0 * spect) * att;
			c.a = s.Alpha;
			return c;
		}	


		//GI
		float _Grain;
		float _Knee;
		float _Compress;

		inline half3 TonemapLight(half3 i)
		{
			i *= _Grain;
			return (i> _Knee) ? (((i-_Knee)*_Compress) + _Knee) : i;
		}

		inline half4 LightingStandardDefaultGI (SurfaceOutputStandard  s, half3 viewDir, UnityGI gi)
		{
			return LightingStandard(s, viewDir, gi);
		}

		inline void LightingStandardDefaultGI_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi);

			gi.light.color = TonemapLight(gi.light.color);
			#ifdef DIRLIGHTMAP_SEPERATE
				#ifdef LIGHTMAP_ON
					gi.light2.color = TonemapLight(gi.light2.color);
				#endif

				#ifdef DYNAMICLIGHTMAP_ON
					gi.light3.color = TonemapLight(gi.light3.color);
				#endif
			#endif
			gi.indirect.diffuse	= TonemapLight(gi.indirect.diffuse);
			gi.indirect.specular = TonemapLight(gi.indirect.specular);
		}
		//

		struct Input
		{
			float2 uv_MainTexture;
		};

		sampler2D _MainTexture;

		/*void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTexture, IN.uv_MainTexture).rgb;
		}*/

		//for spectular
		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			o.Albedo = tex2D(_MainTexture, IN.uv_MainTexture).rgb;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
