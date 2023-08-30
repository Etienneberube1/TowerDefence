// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Robo shaders/Structures_ LWRP"
{
    Properties
    {
		_Paintedcolor("Painted color", Color) = (0.5566038,0.1444019,0.1444019,0)
		_Tint("Tint", Color) = (0.6981132,0.5566645,0.4511392,0)
		_Brightness("Brightness", Range( 0 , 2)) = 1
		[HDR]_Emissivecolor("Emissive color", Color) = (0,0,0,0)
		[Toggle]_Fresnel("Fresnel", Float) = 0
		[HDR]_Fresnelcolor("Fresnel color", Color) = (1,0.0235849,0.0235849,0)
		_Fresnelfalloff("Fresnel falloff", Range( 0 , 5)) = 1
		_Desaturation("Desaturation", Range( 0 , 1)) = 0
		[Toggle]_Desaturationaffectsemission("Desaturation affects emission", Float) = 1
		_Flickeringintensity("Flickering intensity", Range( 1 , 20)) = 0
		[Toggle]_Continuousflickering("Continuous flickering", Float) = 0
		_Minimumsmoothness("Minimum smoothness", Range( 0 , 0.9)) = 0
		_Minimumsmoothnesspainted("Minimum smoothness (painted)", Range( 0 , 0.9)) = 0
		_Albedo("Albedo", 2D) = "white" {}
		_Paintedmask("Painted mask", 2D) = "black" {}
		_Tintmask("Tint mask", 2D) = "black" {}
		_Normal("Normal", 2D) = "bump" {}
		_MetalSmoothness("Metal Smoothness", 2D) = "gray" {}
		_Emissive("Emissive", 2D) = "black" {}
		_Flickermask("Flicker mask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }


    SubShader
    {
		
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
        Pass
        {
			
        	Tags { "LightMode"="LightweightForward" }

        	Name "Base"
			Blend One Zero
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
        	#define _NORMALMAP 1


        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

			sampler2D _Albedo;
			float4 _Albedo_ST;
			float _Brightness;
			sampler2D _Paintedmask;
			float4 _Paintedmask_ST;
			float4 _Paintedcolor;
			float4 _Tint;
			sampler2D _Tintmask;
			float4 _Tintmask_ST;
			sampler2D _Emissive;
			float4 _Emissive_ST;
			float4 _Emissivecolor;
			float _Desaturation;
			sampler2D _Normal;
			float4 _Normal_ST;
			float _Fresnel;
			float _Desaturationaffectsemission;
			float _Continuousflickering;
			float _Flickeringintensity;
			sampler2D _Flickermask;
			float4 _Flickermask_ST;
			float4 _Fresnelcolor;
			float _Fresnelfalloff;
			sampler2D _MetalSmoothness;
			float4 _MetalSmoothness_ST;
			float _Minimumsmoothness;
			float _Minimumsmoothnesspainted;

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
    
				float2 uv_Albedo = IN.ase_texcoord7.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
				float2 uv_Paintedmask = IN.ase_texcoord7.xy * _Paintedmask_ST.xy + _Paintedmask_ST.zw;
				float4 tex2DNode12 = tex2D( _Paintedmask, uv_Paintedmask );
				float4 lerpResult96 = lerp( tex2DNode1 , ( tex2DNode1 * _Brightness ) , ( 1.0 - tex2DNode12.r ));
				float4 lerpResult14 = lerp( lerpResult96 , ( _Paintedcolor * lerpResult96 ) , tex2DNode12.r);
				float4 blendOpSrc43 = _Paintedcolor;
				float4 blendOpDest43 = _Tint;
				float2 uv_Tintmask = IN.ase_texcoord7.xy * _Tintmask_ST.xy + _Tintmask_ST.zw;
				float4 lerpResult29 = lerp( lerpResult14 , ( ( saturate( (( blendOpDest43 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest43 ) * ( 1.0 - blendOpSrc43 ) ) : ( 2.0 * blendOpDest43 * blendOpSrc43 ) ) )) * lerpResult96 ) , tex2D( _Tintmask, uv_Tintmask ));
				float2 uv_Emissive = IN.ase_texcoord7.xy * _Emissive_ST.xy + _Emissive_ST.zw;
				float4 tex2DNode16 = tex2D( _Emissive, uv_Emissive );
				float4 lerpResult21 = lerp( lerpResult29 , ( tex2DNode16 * _Emissivecolor ) , tex2DNode16.r);
				float3 desaturateInitialColor50 = lerpResult21.rgb;
				float desaturateDot50 = dot( desaturateInitialColor50, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar50 = lerp( desaturateInitialColor50, desaturateDot50.xxx, _Desaturation );
				
				float2 uv_Normal = IN.ase_texcoord7.xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 tex2DNode4 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), 1.0f );
				
				float2 uv_Flickermask = IN.ase_texcoord7.xy * _Flickermask_ST.xy + _Flickermask_ST.zw;
				float4 lerpResult68 = lerp( _Emissivecolor , ( _Emissivecolor * max( ( lerp(max( _SinTime.z , 0.0 ),abs( _SinTime.z ),_Continuousflickering) * _Flickeringintensity ) , 1.0 ) ) , tex2D( _Flickermask, uv_Flickermask ));
				float4 temp_output_18_0 = ( tex2DNode16 * lerpResult68 );
				float3 desaturateInitialColor55 = temp_output_18_0.rgb;
				float desaturateDot55 = dot( desaturateInitialColor55, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar55 = lerp( desaturateInitialColor55, desaturateDot55.xxx, _Desaturation );
				float3 tanToWorld0 = float3( WorldSpaceTangent.x, WorldSpaceBiTangent.x, WorldSpaceNormal.x );
				float3 tanToWorld1 = float3( WorldSpaceTangent.y, WorldSpaceBiTangent.y, WorldSpaceNormal.y );
				float3 tanToWorld2 = float3( WorldSpaceTangent.z, WorldSpaceBiTangent.z, WorldSpaceNormal.z );
				float3 tanNormal79 = tex2DNode4;
				float fresnelNdotV79 = dot( float3(dot(tanToWorld0,tanNormal79), dot(tanToWorld1,tanNormal79), dot(tanToWorld2,tanNormal79)), WorldSpaceViewDirection );
				float fresnelNode79 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV79, _Fresnelfalloff ) );
				float4 lerpResult92 = lerp( lerp(temp_output_18_0,float4( desaturateVar55 , 0.0 ),_Desaturationaffectsemission) , _Fresnelcolor , min( fresnelNode79 , 1.0 ));
				
				float2 uv_MetalSmoothness = IN.ase_texcoord7.xy * _MetalSmoothness_ST.xy + _MetalSmoothness_ST.zw;
				float4 tex2DNode3 = tex2D( _MetalSmoothness, uv_MetalSmoothness );
				float4 appendResult11 = (float4(tex2DNode3.r , tex2DNode3.g , tex2DNode3.b , 0.0));
				
				float lerpResult24 = lerp( max( tex2DNode3.a , _Minimumsmoothness ) , max( tex2DNode3.a , _Minimumsmoothnesspainted ) , tex2DNode12.r);
				
				
		        float3 Albedo = desaturateVar50;
				float3 Normal = tex2DNode4;
				float3 Emission = lerp(lerp(temp_output_18_0,float4( desaturateVar55 , 0.0 ),_Desaturationaffectsemission),lerpResult92,_Fresnel).rgb;
				float3 Specular = float3(0.5, 0.5, 0.5);
				float Metallic = appendResult11.x;
				float Smoothness = lerpResult24;
				float Occlusion = 1;
				float Alpha = 1;
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
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			
        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
        	};

			
            // x: global clip space bias, y: normal world space bias
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v )
        	{
        	    VertexOutput o;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

				
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

               

				float Alpha = 1;
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

			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

			           

            VertexOutput vert(GraphVertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
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

				

				float Alpha = 1;
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

			sampler2D _Albedo;
			float4 _Albedo_ST;
			float _Brightness;
			sampler2D _Paintedmask;
			float4 _Paintedmask_ST;
			float4 _Paintedcolor;
			float4 _Tint;
			sampler2D _Tintmask;
			float4 _Tintmask_ST;
			sampler2D _Emissive;
			float4 _Emissive_ST;
			float4 _Emissivecolor;
			float _Desaturation;
			float _Fresnel;
			float _Desaturationaffectsemission;
			float _Continuousflickering;
			float _Flickeringintensity;
			sampler2D _Flickermask;
			float4 _Flickermask_ST;
			float4 _Fresnelcolor;
			sampler2D _Normal;
			float4 _Normal_ST;
			float _Fresnelfalloff;

            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_texcoord1 : TEXCOORD1;
                float4 ase_texcoord2 : TEXCOORD2;
                float4 ase_texcoord3 : TEXCOORD3;
                float4 ase_texcoord4 : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

			
            VertexOutput vert(GraphVertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;

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

           		float2 uv_Albedo = IN.ase_texcoord.xy * _Albedo_ST.xy + _Albedo_ST.zw;
           		float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
           		float2 uv_Paintedmask = IN.ase_texcoord.xy * _Paintedmask_ST.xy + _Paintedmask_ST.zw;
           		float4 tex2DNode12 = tex2D( _Paintedmask, uv_Paintedmask );
           		float4 lerpResult96 = lerp( tex2DNode1 , ( tex2DNode1 * _Brightness ) , ( 1.0 - tex2DNode12.r ));
           		float4 lerpResult14 = lerp( lerpResult96 , ( _Paintedcolor * lerpResult96 ) , tex2DNode12.r);
           		float4 blendOpSrc43 = _Paintedcolor;
           		float4 blendOpDest43 = _Tint;
           		float2 uv_Tintmask = IN.ase_texcoord.xy * _Tintmask_ST.xy + _Tintmask_ST.zw;
           		float4 lerpResult29 = lerp( lerpResult14 , ( ( saturate( (( blendOpDest43 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest43 ) * ( 1.0 - blendOpSrc43 ) ) : ( 2.0 * blendOpDest43 * blendOpSrc43 ) ) )) * lerpResult96 ) , tex2D( _Tintmask, uv_Tintmask ));
           		float2 uv_Emissive = IN.ase_texcoord.xy * _Emissive_ST.xy + _Emissive_ST.zw;
           		float4 tex2DNode16 = tex2D( _Emissive, uv_Emissive );
           		float4 lerpResult21 = lerp( lerpResult29 , ( tex2DNode16 * _Emissivecolor ) , tex2DNode16.r);
           		float3 desaturateInitialColor50 = lerpResult21.rgb;
           		float desaturateDot50 = dot( desaturateInitialColor50, float3( 0.299, 0.587, 0.114 ));
           		float3 desaturateVar50 = lerp( desaturateInitialColor50, desaturateDot50.xxx, _Desaturation );
           		
           		float2 uv_Flickermask = IN.ase_texcoord.xy * _Flickermask_ST.xy + _Flickermask_ST.zw;
           		float4 lerpResult68 = lerp( _Emissivecolor , ( _Emissivecolor * max( ( lerp(max( _SinTime.z , 0.0 ),abs( _SinTime.z ),_Continuousflickering) * _Flickeringintensity ) , 1.0 ) ) , tex2D( _Flickermask, uv_Flickermask ));
           		float4 temp_output_18_0 = ( tex2DNode16 * lerpResult68 );
           		float3 desaturateInitialColor55 = temp_output_18_0.rgb;
           		float desaturateDot55 = dot( desaturateInitialColor55, float3( 0.299, 0.587, 0.114 ));
           		float3 desaturateVar55 = lerp( desaturateInitialColor55, desaturateDot55.xxx, _Desaturation );
           		float3 ase_worldPos = IN.ase_texcoord1.xyz;
           		float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
           		ase_worldViewDir = normalize(ase_worldViewDir);
           		float2 uv_Normal = IN.ase_texcoord.xy * _Normal_ST.xy + _Normal_ST.zw;
           		float3 tex2DNode4 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), 1.0f );
           		float3 ase_worldTangent = IN.ase_texcoord2.xyz;
           		float3 ase_worldNormal = IN.ase_texcoord3.xyz;
           		float3 ase_worldBitangent = IN.ase_texcoord4.xyz;
           		float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
           		float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
           		float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
           		float3 tanNormal79 = tex2DNode4;
           		float fresnelNdotV79 = dot( float3(dot(tanToWorld0,tanNormal79), dot(tanToWorld1,tanNormal79), dot(tanToWorld2,tanNormal79)), ase_worldViewDir );
           		float fresnelNode79 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV79, _Fresnelfalloff ) );
           		float4 lerpResult92 = lerp( lerp(temp_output_18_0,float4( desaturateVar55 , 0.0 ),_Desaturationaffectsemission) , _Fresnelcolor , min( fresnelNode79 , 1.0 ));
           		
				
		        float3 Albedo = desaturateVar50;
				float3 Emission = lerp(lerp(temp_output_18_0,float4( desaturateVar55 , 0.0 ),_Desaturationaffectsemission),lerpResult92,_Fresnel).rgb;
				float Alpha = 1;
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
2640;364;1920;1019;1586.532;1259.19;2.195686;True;True
Node;AmplifyShaderEditor.CommentaryNode;74;-1419.583,533.0792;Float;False;3038.762;1386.438;Flickering and emission;15;18;71;16;68;63;69;17;66;64;67;61;65;56;77;78;;0.3726415,0.9514498,1,1;0;0
Node;AmplifyShaderEditor.SinTimeNode;56;-1344.4,1123.379;Float;True;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;61;-983.1148,1261.819;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;77;-1002.656,963.9825;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;78;-683.2754,1132.079;Float;False;Property;_Continuousflickering;Continuous flickering;11;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-985.8378,1538.471;Float;False;Property;_Flickeringintensity;Flickering intensity;10;0;Create;True;0;0;False;0;0;14.55;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-172.3413,1556.779;Float;False;Constant;_1;1;15;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-272.8212,1228.025;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1416.244,-663.5305;Float;True;Property;_Albedo;Albedo;14;0;Create;True;0;0;False;0;51ed1188220a98742ad3c1cb24213833;51ed1188220a98742ad3c1cb24213833;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;98;-1400.926,-354.4675;Float;False;Property;_Brightness;Brightness;2;0;Create;True;0;0;False;0;1;0.8;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-1433.953,-958.6374;Float;True;Property;_Paintedmask;Painted mask;15;0;Create;True;0;0;False;0;b34437b3a84071b448b8a3264164ae12;b34437b3a84071b448b8a3264164ae12;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;17;-387.0074,930.6396;Float;False;Property;_Emissivecolor;Emissive color;3;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1.844303,0.4055535,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;66;132.0869,1189.859;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-947.0267,-475.2675;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;95;-977.9243,-1017.764;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;69;216.34,1530.815;Float;True;Property;_Flickermask;Flicker mask;20;0;Create;True;0;0;False;0;7bf2cf885c389ff4aaa2749b35a58073;7bf2cf885c389ff4aaa2749b35a58073;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;362.6747,1002.701;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;13;-685.1962,-1205.072;Float;False;Property;_Paintedcolor;Painted color;0;0;Create;True;0;0;False;0;0.5566038,0.1444019,0.1444019,0;0,0.4528302,0.08156572,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-205.7993,678.7603;Float;True;Property;_Emissive;Emissive;19;0;Create;True;0;0;False;0;fc208b44be1bdff4a8cc42550aa2408d;fc208b44be1bdff4a8cc42550aa2408d;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;68;730.62,898.7475;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;96;-601.5256,-736.0508;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;41;-381.9552,-1437.533;Float;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;0.6981132,0.5566645,0.4511392,0;0.6981132,0.5566645,0.4511392,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;1018.25,795.3264;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;1644.415,1349.054;Float;True;Property;_Normal;Normal;17;0;Create;True;0;0;False;0;10afce0a9c4cf0e43a53f7bb1adf382d;10afce0a9c4cf0e43a53f7bb1adf382d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;80;1677.58,-731.702;Float;False;Property;_Fresnelfalloff;Fresnel falloff;6;0;Create;True;0;0;False;0;1;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;43;48.96292,-1193.271;Float;True;Overlay;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-208.3365,-1056.166;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;51;1271.396,-553.3268;Float;False;Property;_Desaturation;Desaturation;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;2.952917,-925.175;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;464.3654,-904.7229;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;42;51.32484,-501.4227;Float;True;Property;_Tintmask;Tint mask;16;0;Create;True;0;0;False;0;c0cb4e77c1a95e64091c6170db0d8480;c0cb4e77c1a95e64091c6170db0d8480;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;55;1738.187,690.6838;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;94;2183.584,-951.319;Float;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;79;2070.51,-786.7838;Float;True;Standard;TangentNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;548.6495,717.7595;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;29;850.4943,-593.8394;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;93;2410.185,-813.9788;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;54;1897.636,325.2408;Float;False;Property;_Desaturationaffectsemission;Desaturation affects emission;8;0;Create;True;0;0;False;0;1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;82;2202.386,-488.3745;Float;False;Property;_Fresnelcolor;Fresnel color;5;1;[HDR];Create;True;0;0;False;0;1,0.0235849,0.0235849,0;0,0.9956001,0.09370355,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;92;2822.708,-499.8199;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;21;1290.605,-365.8694;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;76;-712.8096,-273.8701;Float;False;1449.942;738.7083;Metallick smoothness;7;3;22;25;23;26;24;11;;0.3537736,1,0.5451297,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;497.132,-223.8701;Float;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-449.1956,225.6679;Float;False;Property;_Minimumsmoothnesspainted;Minimum smoothness (painted);13;0;Create;True;0;0;False;0;0;0.119;0;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-662.8096,-125.3103;Float;True;Property;_MetalSmoothness;Metal Smoothness;18;0;Create;True;0;0;False;0;10754defc646d824c8151442ade4b5b7;10754defc646d824c8151442ade4b5b7;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-313.4379,349.8382;Float;False;Property;_Minimumsmoothness;Minimum smoothness;12;0;Create;True;0;0;False;0;0;0.573;0;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;50;1796.469,-159.0599;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;85;3117.823,-5.025851;Float;False;Property;_Fresnel;Fresnel;4;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;24;537.6695,98.14299;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;23;201.171,206.6548;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;26;98.9741,87.28218;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;62;1694.726,885.9152;Float;True;Property;_Flickering;Flickering;9;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;99;3530.12,309.1885;Float;False;True;2;Float;ASEMaterialInspector;0;2;Robo shaders/Structures_ LWRP;1976390536c6c564abb90fe41f6ee334;True;Base;0;0;Base;11;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;Hidden/InternalErrorShader;0;0;Standard;2;Vertex Position,InvertActionOnDeselection;1;Receive Shadows;1;1;_FinalColorxAlpha;0;4;True;True;True;True;False;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;101;3413.466,142.1859;Float;False;False;2;Float;ASEMaterialInspector;0;10;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;102;3413.466,142.1859;Float;False;False;2;Float;ASEMaterialInspector;0;10;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;100;3413.466,142.1859;Float;False;False;2;Float;ASEMaterialInspector;0;10;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
WireConnection;61;0;56;3
WireConnection;77;0;56;3
WireConnection;78;0;77;0
WireConnection;78;1;61;0
WireConnection;64;0;78;0
WireConnection;64;1;65;0
WireConnection;66;0;64;0
WireConnection;66;1;67;0
WireConnection;97;0;1;0
WireConnection;97;1;98;0
WireConnection;95;0;12;1
WireConnection;63;0;17;0
WireConnection;63;1;66;0
WireConnection;68;0;17;0
WireConnection;68;1;63;0
WireConnection;68;2;69;0
WireConnection;96;0;1;0
WireConnection;96;1;97;0
WireConnection;96;2;95;0
WireConnection;18;0;16;0
WireConnection;18;1;68;0
WireConnection;43;0;13;0
WireConnection;43;1;41;0
WireConnection;15;0;13;0
WireConnection;15;1;96;0
WireConnection;14;0;96;0
WireConnection;14;1;15;0
WireConnection;14;2;12;1
WireConnection;44;0;43;0
WireConnection;44;1;96;0
WireConnection;55;0;18;0
WireConnection;55;1;51;0
WireConnection;79;0;4;0
WireConnection;79;3;80;0
WireConnection;71;0;16;0
WireConnection;71;1;17;0
WireConnection;29;0;14;0
WireConnection;29;1;44;0
WireConnection;29;2;42;0
WireConnection;93;0;79;0
WireConnection;93;1;94;0
WireConnection;54;0;18;0
WireConnection;54;1;55;0
WireConnection;92;0;54;0
WireConnection;92;1;82;0
WireConnection;92;2;93;0
WireConnection;21;0;29;0
WireConnection;21;1;71;0
WireConnection;21;2;16;1
WireConnection;11;0;3;1
WireConnection;11;1;3;2
WireConnection;11;2;3;3
WireConnection;50;0;21;0
WireConnection;50;1;51;0
WireConnection;85;0;54;0
WireConnection;85;1;92;0
WireConnection;24;0;23;0
WireConnection;24;1;26;0
WireConnection;24;2;12;1
WireConnection;23;0;3;4
WireConnection;23;1;22;0
WireConnection;26;0;3;4
WireConnection;26;1;25;0
WireConnection;99;0;50;0
WireConnection;99;1;4;0
WireConnection;99;2;85;0
WireConnection;99;3;11;0
WireConnection;99;4;24;0
ASEEND*/
//CHKSM=C4C85FCFB45CBCA1E7B7E8DE29952F25FEE15C7C