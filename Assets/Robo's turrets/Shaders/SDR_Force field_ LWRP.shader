// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Robo shaders/Force field"
{
    Properties
    {
		[HDR]_Maincolor("Main color", Color) = (0,0.8490566,0.8111528,0)
		_Alphatiling("Alpha tiling", Vector) = (1,1,0,0)
		_VGradientfalloff("VGradient falloff", Range( 1 , 5)) = 0
		_Minimumopacity("Minimum opacity", Range( 0 , 1)) = 0
		_Pulsepower("Pulse power", Range( 1 , 5)) = 0
		[Toggle]_Alphaaffectsopacity("Alpha affects opacity", Float) = 0
		_Opacityintensity("Opacity intensity", Range( 0 , 1)) = 0
		_Alpha("Alpha", 2D) = "white" {}
		_Alphawaved("Alphawaved", 2D) = "white" {}
		_PannerspeedU("Panner speed U", Range( -2 , 2)) = 0.1
		_PannerspeedV("Panner speed V", Range( -2 , 2)) = 0.1
		_Wavetexture("Wave texture", 2D) = "white" {}
		_Wavetiling("Wave tiling", Vector) = (1,1,0,0)
		_Waveintensity("Wave intensity", Range( 1 , 5)) = 1
		_WavespeedU("Wave speed U", Range( -2 , 2)) = 0.1
		_WavespeedV("Wave speed V", Range( -2 , 2)) = 0.1
    }


    SubShader
    {
		
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
        Pass
        {
			
        	Tags { "LightMode"="LightweightForward" }

        	Name "Base"
			Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
            
        	HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

        	#define ASE_SRP_VERSION 51601


        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

			float4 _Maincolor;
			sampler2D _Alpha;
			float2 _Alphatiling;
			float _PannerspeedU;
			float _PannerspeedV;
			float _Waveintensity;
			sampler2D _Wavetexture;
			float2 _Wavetiling;
			float _WavespeedU;
			float _WavespeedV;
			sampler2D _Alphawaved;
			float _Pulsepower;
			float _Alphaaffectsopacity;
			float _VGradientfalloff;
			float _Minimumopacity;
			float _Opacityintensity;

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                float4 lightmapUVOrVertexSH	  : TEXCOORD0;
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;
				float4 tSpace0					: TEXCOORD3;
				float4 tSpace1					: TEXCOORD4;
				float4 tSpace2					: TEXCOORD5;
				float4 ase_texcoord7 : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };

			
            GraphVertexOutput vert (GraphVertexInput v  )
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				float3 vertexValue =  float3( 0, 0, 0 ) ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal =  v.ase_normal ;

        		// Vertex shader outputs defined by graph
                float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
        	    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
        	    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
        	    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN  ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

        		float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );
    
				float4 appendResult23 = (float4(_PannerspeedU , _PannerspeedV , 0.0 , 0.0));
				float2 uv020 = IN.ase_texcoord7.xy * _Alphatiling + ( appendResult23 * _Time.y ).xy;
				float2 panner14 = ( 1.0 * _Time.y * float2( 0,0 ) + uv020);
				float4 tex2DNode4 = tex2D( _Alpha, panner14 );
				float4 appendResult31 = (float4(_WavespeedU , _WavespeedV , 0.0 , 0.0));
				float2 uv035 = IN.ase_texcoord7.xy * _Wavetiling + ( appendResult31 * _Time.y ).xy;
				float2 panner36 = ( 1.0 * _Time.y * float2( 0,0 ) + uv035);
				float4 blendOpSrc26 = ( ( _Maincolor * tex2DNode4 ) * float4( 0.5019608,0.5019608,0.5019608,0 ) );
				float4 blendOpDest26 = ( ( _Waveintensity * tex2D( _Wavetexture, panner36 ) ) * tex2D( _Alphawaved, panner14 ) );
				float2 uv054 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float4 temp_output_57_0 = ( ( blendOpSrc26 + blendOpDest26 ) * max( 1.0 , abs( ( ( ( 1.0 - uv054.y ) * _SinTime.z ) * _Pulsepower ) ) ) );
				
				float2 uv037 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_48_0 = max( pow( ( 1.0 - ( uv037.y * 1.0 ) ) , _VGradientfalloff ) , _Minimumopacity );
				float4 temp_cast_4 = (temp_output_48_0).xxxx;
				float4 temp_cast_5 = (_Opacityintensity).xxxx;
				float4 temp_output_80_0 = min( lerp(temp_cast_4,( tex2DNode4 * temp_output_48_0 ),_Alphaaffectsopacity) , temp_cast_5 );
				
				
		        float3 Albedo = temp_output_57_0.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = temp_output_57_0.rgb;
				float3 Specular = float3(0.5, 0.5, 0.5);
				float Metallic = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = temp_output_80_0.r;
				float AlphaClipThreshold = 0;

        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;

        #ifdef _NORMALMAP
        	    inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
        #else
            #if !SHADER_HINT_NICE_QUALITY
                inputData.normalWS = WorldSpaceNormal;
            #else
        	    inputData.normalWS = normalize(WorldSpaceNormal);
            #endif
        #endif

        #if !SHADER_HINT_NICE_QUALITY
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
        #else
        	    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
        #endif

        	    inputData.shadowCoord = IN.shadowCoord;

        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);

        		half4 color = LightweightFragmentPBR(
        			inputData, 
        			Albedo, 
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

			#ifdef TERRAIN_SPLAT_ADDPASS
				color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
			#else
				color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
			#endif

        #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

		#if ASE_LW_FINAL_COLOR_ALPHA_MULTIPLY
				color.rgb *= color.a;
		#endif
        		return color;
            }

        	ENDHLSL
        }

		
        Pass
        {
			
        	Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #define ASE_SRP_VERSION 51601


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			float _Alphaaffectsopacity;
			float _VGradientfalloff;
			float _Minimumopacity;
			sampler2D _Alpha;
			float2 _Alphatiling;
			float _PannerspeedU;
			float _PannerspeedV;
			float _Opacityintensity;

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord7 : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
        	};

			
            // x: global clip space bias, y: normal world space bias
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v )
        	{
        	    VertexOutput o;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				float3 vertexValue =  float3(0,0,0) ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;

        	    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;

                // normal bias is negative since we want to apply an inset normal offset
                positionWS = _LightDirection * _ShadowBias.xxx + positionWS;
				positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);

                // _ShadowBias.x sign depens on if platform has reversed z buffer
                //clipPos.z += _ShadowBias.x;

        	#if UNITY_REVERSED_Z
        	    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#else
        	    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#endif
                o.clipPos = clipPos;

        	    return o;
        	}

            half4 ShadowPassFragment(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

               float2 uv037 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
               float temp_output_48_0 = max( pow( ( 1.0 - ( uv037.y * 1.0 ) ) , _VGradientfalloff ) , _Minimumopacity );
               float4 temp_cast_0 = (temp_output_48_0).xxxx;
               float4 appendResult23 = (float4(_PannerspeedU , _PannerspeedV , 0.0 , 0.0));
               float2 uv020 = IN.ase_texcoord7.xy * _Alphatiling + ( appendResult23 * _Time.y ).xy;
               float2 panner14 = ( 1.0 * _Time.y * float2( 0,0 ) + uv020);
               float4 tex2DNode4 = tex2D( _Alpha, panner14 );
               float4 temp_cast_2 = (_Opacityintensity).xxxx;
               float4 temp_output_80_0 = min( lerp(temp_cast_0,( tex2DNode4 * temp_output_48_0 ),_Alphaaffectsopacity) , temp_cast_2 );
               

				float Alpha = temp_output_80_0.r;
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }

            ENDHLSL
        }

		
        Pass
        {
			
        	Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }

            ZWrite On
			ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #define ASE_SRP_VERSION 51601


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			float _Alphaaffectsopacity;
			float _VGradientfalloff;
			float _Minimumopacity;
			sampler2D _Alpha;
			float2 _Alphatiling;
			float _PannerspeedU;
			float _PannerspeedV;
			float _Opacityintensity;

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

			           

            VertexOutput vert(GraphVertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				float3 vertexValue =  float3(0,0,0) ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

				float2 uv037 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_48_0 = max( pow( ( 1.0 - ( uv037.y * 1.0 ) ) , _VGradientfalloff ) , _Minimumopacity );
				float4 temp_cast_0 = (temp_output_48_0).xxxx;
				float4 appendResult23 = (float4(_PannerspeedU , _PannerspeedV , 0.0 , 0.0));
				float2 uv020 = IN.ase_texcoord.xy * _Alphatiling + ( appendResult23 * _Time.y ).xy;
				float2 panner14 = ( 1.0 * _Time.y * float2( 0,0 ) + uv020);
				float4 tex2DNode4 = tex2D( _Alpha, panner14 );
				float4 temp_cast_2 = (_Opacityintensity).xxxx;
				float4 temp_output_80_0 = min( lerp(temp_cast_0,( tex2DNode4 * temp_output_48_0 ),_Alphaaffectsopacity) , temp_cast_2 );
				

				float Alpha = temp_output_80_0.r;
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
		
        Pass
        {
			
        	Name "Meta"
            Tags { "LightMode"="Meta" }

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex vert
            #pragma fragment frag

            #define ASE_SRP_VERSION 51601


			uniform float4 _MainTex_ST;
			
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			float4 _Maincolor;
			sampler2D _Alpha;
			float2 _Alphatiling;
			float _PannerspeedU;
			float _PannerspeedV;
			float _Waveintensity;
			sampler2D _Wavetexture;
			float2 _Wavetiling;
			float _WavespeedU;
			float _WavespeedV;
			sampler2D _Alphawaved;
			float _Pulsepower;
			float _Alphaaffectsopacity;
			float _VGradientfalloff;
			float _Minimumopacity;
			float _Opacityintensity;

            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

			
            VertexOutput vert(GraphVertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				float3 vertexValue =  float3(0,0,0) ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;
#if !defined( ASE_SRP_VERSION ) || ASE_SRP_VERSION  > 51300				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST);
#else
				o.clipPos = MetaVertexPosition (v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST);
#endif
        	    return o;
            }

            half4 frag(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float4 appendResult23 = (float4(_PannerspeedU , _PannerspeedV , 0.0 , 0.0));
           		float2 uv020 = IN.ase_texcoord.xy * _Alphatiling + ( appendResult23 * _Time.y ).xy;
           		float2 panner14 = ( 1.0 * _Time.y * float2( 0,0 ) + uv020);
           		float4 tex2DNode4 = tex2D( _Alpha, panner14 );
           		float4 appendResult31 = (float4(_WavespeedU , _WavespeedV , 0.0 , 0.0));
           		float2 uv035 = IN.ase_texcoord.xy * _Wavetiling + ( appendResult31 * _Time.y ).xy;
           		float2 panner36 = ( 1.0 * _Time.y * float2( 0,0 ) + uv035);
           		float4 blendOpSrc26 = ( ( _Maincolor * tex2DNode4 ) * float4( 0.5019608,0.5019608,0.5019608,0 ) );
           		float4 blendOpDest26 = ( ( _Waveintensity * tex2D( _Wavetexture, panner36 ) ) * tex2D( _Alphawaved, panner14 ) );
           		float2 uv054 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
           		float4 temp_output_57_0 = ( ( blendOpSrc26 + blendOpDest26 ) * max( 1.0 , abs( ( ( ( 1.0 - uv054.y ) * _SinTime.z ) * _Pulsepower ) ) ) );
           		
           		float2 uv037 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
           		float temp_output_48_0 = max( pow( ( 1.0 - ( uv037.y * 1.0 ) ) , _VGradientfalloff ) , _Minimumopacity );
           		float4 temp_cast_4 = (temp_output_48_0).xxxx;
           		float4 temp_cast_5 = (_Opacityintensity).xxxx;
           		float4 temp_output_80_0 = min( lerp(temp_cast_4,( tex2DNode4 * temp_output_48_0 ),_Alphaaffectsopacity) , temp_cast_5 );
           		
				
		        float3 Albedo = temp_output_57_0.rgb;
				float3 Emission = temp_output_57_0.rgb;
				float Alpha = temp_output_80_0.r;
				float AlphaClipThreshold = 0;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = Albedo;
                metaInput.Emission = Emission;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
        }
		
    }
    Fallback "Hidden/InternalErrorShader"
	CustomEditor "ASEMaterialInspector"
	
}
/*ASEBEGIN
Version=16800
2560;147;1920;1019;-360.7072;376.055;1.3;True;True
Node;AmplifyShaderEditor.RangedFloatNode;22;-2367.015,265.347;Float;False;Property;_PannerspeedV;Panner speed V;10;0;Create;True;0;0;False;0;0.1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2366.89,122.9339;Float;False;Property;_PannerspeedU;Panner speed U;9;0;Create;True;0;0;False;0;0.1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2646.04,-323.6983;Float;False;Property;_WavespeedV;Wave speed V;15;0;Create;True;0;0;False;0;0.1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2647.328,-440.6877;Float;False;Property;_WavespeedU;Wave speed U;14;0;Create;True;0;0;False;0;0.1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;32;-2349.926,-189.4878;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;23;-2019.355,195.8724;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TimeNode;18;-2044.512,590.9689;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;31;-2319.565,-388.9355;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1770.153,411.0246;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;33;-2050.956,-608.7442;Float;False;Property;_Wavetiling;Wave tiling;12;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;21;-1774.322,99.4932;Float;False;Property;_Alphatiling;Alpha tiling;1;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-1137.449,552.5103;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-1059.155,739.3571;Float;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2027.566,-286.9355;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-1472.938,233.0361;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1766.678,-475.4999;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;54;-920.2672,1060.668;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-763.5531,636.4408;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;56;-568.0711,1107.34;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;36;-1400.412,-451.7023;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;14;-1098.264,234.8976;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;40;-435.7363,633.03;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-515.2125,919.5133;Float;False;Property;_VGradientfalloff;VGradient falloff;2;0;Create;True;0;0;False;0;0;2.41;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;52;-555.4741,1245.042;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;47;-133.379,632.9221;Float;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1027.98,-677.9818;Float;False;Property;_Waveintensity;Wave intensity;13;0;Create;True;0;0;False;0;1;2.55;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-86.97388,920.5609;Float;False;Property;_Minimumopacity;Minimum opacity;3;0;Create;True;0;0;False;0;0;0.059;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-764.4891,305.377;Float;True;Property;_Alpha;Alpha;7;0;Create;True;0;0;False;0;094f846ca2a7f914ea23ab361f958db7;094f846ca2a7f914ea23ab361f958db7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-703.0065,89.03034;Float;False;Property;_Maincolor;Main color;0;1;[HDR];Create;True;0;0;False;0;0,0.8490566,0.8111528,0;2.996078,0.6499323,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-322.2048,1402.246;Float;False;Property;_Pulsepower;Pulse power;4;0;Create;True;0;0;False;0;0;1.14;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-1118.471,-488.8605;Float;True;Property;_Wavetexture;Wave texture;11;0;Create;True;0;0;False;0;6a02d582da740d3419bcc57e545919b7;6a02d582da740d3419bcc57e545919b7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-289.8178,1128.137;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;48;263.8745,630.4084;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;4.79579,1127.562;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-717.6592,-166.7579;Float;True;Property;_Alphawaved;Alphawaved;8;0;Create;True;0;0;True;0;f3ea5d9b6f545234ca770153b2cb1ace;f3ea5d9b6f545234ca770153b2cb1ace;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-358.1589,93.19016;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-620.6795,-579.0248;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;59;209.8617,1125.845;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-47.23907,91.65916;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.5019608,0.5019608,0.5019608,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-266.4633,-299.9846;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;551.7339,336.5399;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;60;399.6199,1101.459;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;26;250.3345,-180.0695;Float;True;LinearDodge;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;75;961.5986,287.1136;Float;False;Property;_Alphaaffectsopacity;Alpha affects opacity;5;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;78;917.4106,439.1255;Float;False;Property;_Opacityintensity;Opacity intensity;6;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;80;1316.059,336.2988;Float;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;1682.785,-137.4957;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;1080.671,-26.95105;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;91;1741.823,235.9542;Float;False;False;2;Float;ASEMaterialInspector;0;10;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;88;1838.823,106.9542;Float;False;True;2;Float;ASEMaterialInspector;0;2;Robo shaders/Force field;1976390536c6c564abb90fe41f6ee334;True;Base;0;0;Base;11;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;1;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;Hidden/InternalErrorShader;0;0;Standard;2;Vertex Position,InvertActionOnDeselection;1;Receive Shadows;1;1;_FinalColorxAlpha;0;4;True;True;True;True;False;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;90;1741.823,235.9542;Float;False;False;2;Float;ASEMaterialInspector;0;10;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;89;1741.823,235.9542;Float;False;False;2;Float;ASEMaterialInspector;0;10;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
WireConnection;23;0;19;0
WireConnection;23;1;22;0
WireConnection;31;0;30;0
WireConnection;31;1;29;0
WireConnection;24;0;23;0
WireConnection;24;1;18;2
WireConnection;34;0;31;0
WireConnection;34;1;32;2
WireConnection;20;0;21;0
WireConnection;20;1;24;0
WireConnection;35;0;33;0
WireConnection;35;1;34;0
WireConnection;38;0;37;2
WireConnection;38;1;39;0
WireConnection;56;0;54;2
WireConnection;36;0;35;0
WireConnection;14;0;20;0
WireConnection;40;0;38;0
WireConnection;47;0;40;0
WireConnection;47;1;46;0
WireConnection;4;1;14;0
WireConnection;27;1;36;0
WireConnection;55;0;56;0
WireConnection;55;1;52;3
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;62;0;55;0
WireConnection;62;1;63;0
WireConnection;5;1;14;0
WireConnection;15;0;3;0
WireConnection;15;1;4;0
WireConnection;73;0;74;0
WireConnection;73;1;27;0
WireConnection;59;0;62;0
WireConnection;50;0;15;0
WireConnection;28;0;73;0
WireConnection;28;1;5;0
WireConnection;76;0;4;0
WireConnection;76;1;48;0
WireConnection;60;1;59;0
WireConnection;26;0;50;0
WireConnection;26;1;28;0
WireConnection;75;0;48;0
WireConnection;75;1;76;0
WireConnection;80;0;75;0
WireConnection;80;1;78;0
WireConnection;92;0;57;0
WireConnection;92;1;80;0
WireConnection;57;0;26;0
WireConnection;57;1;60;0
WireConnection;88;0;57;0
WireConnection;88;2;57;0
WireConnection;88;6;80;0
ASEEND*/
//CHKSM=E4BDCAD3E9AE1D8075F6968A75F1EE1BB4C687A8