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
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Maincolor;
		uniform sampler2D _Alpha;
		uniform float2 _Alphatiling;
		uniform float _PannerspeedU;
		uniform float _PannerspeedV;
		uniform float _Waveintensity;
		uniform sampler2D _Wavetexture;
		uniform float2 _Wavetiling;
		uniform float _WavespeedU;
		uniform float _WavespeedV;
		uniform sampler2D _Alphawaved;
		uniform float _Pulsepower;
		uniform float _Alphaaffectsopacity;
		uniform float _VGradientfalloff;
		uniform float _Minimumopacity;
		uniform float _Opacityintensity;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 appendResult23 = (float4(_PannerspeedU , _PannerspeedV , 0.0 , 0.0));
			float2 uv_TexCoord20 = i.uv_texcoord * _Alphatiling + ( appendResult23 * _Time.y ).xy;
			float2 panner14 = ( 1.0 * _Time.y * float2( 0,0 ) + uv_TexCoord20);
			float4 tex2DNode4 = tex2D( _Alpha, panner14 );
			float4 appendResult31 = (float4(_WavespeedU , _WavespeedV , 0.0 , 0.0));
			float2 uv_TexCoord35 = i.uv_texcoord * _Wavetiling + ( appendResult31 * _Time.y ).xy;
			float2 panner36 = ( 1.0 * _Time.y * float2( 0,0 ) + uv_TexCoord35);
			float4 blendOpSrc26 = ( ( _Maincolor * tex2DNode4 ) * float4( 0.5019608,0.5019608,0.5019608,0 ) );
			float4 blendOpDest26 = ( ( _Waveintensity * tex2D( _Wavetexture, panner36 ) ) * tex2D( _Alphawaved, panner14 ) );
			o.Emission = ( ( blendOpSrc26 + blendOpDest26 ) * max( 1.0 , abs( ( ( ( 1.0 - i.uv_texcoord.y ) * _SinTime.z ) * _Pulsepower ) ) ) ).rgb;
			float temp_output_48_0 = max( pow( ( 1.0 - ( i.uv_texcoord.y * 1.0 ) ) , _VGradientfalloff ) , _Minimumopacity );
			float4 temp_cast_3 = (temp_output_48_0).xxxx;
			float4 temp_cast_4 = (_Opacityintensity).xxxx;
			o.Alpha = min( lerp(temp_cast_3,( tex2DNode4 * temp_output_48_0 ),_Alphaaffectsopacity) , temp_cast_4 ).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16301
2560;147;1920;1019;1205.181;1102.085;2.2;True;True
Node;AmplifyShaderEditor.RangedFloatNode;30;-2647.328,-440.6877;Float;False;Property;_WavespeedU;Wave speed U;14;0;Create;True;0;0;False;0;0.1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2646.04,-323.6983;Float;False;Property;_WavespeedV;Wave speed V;15;0;Create;True;0;0;False;0;0.1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2366.89,122.9339;Float;False;Property;_PannerspeedU;Panner speed U;9;0;Create;True;0;0;False;0;0.1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2367.015,265.347;Float;False;Property;_PannerspeedV;Panner speed V;10;0;Create;True;0;0;False;0;0.1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-2019.355,195.8724;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TimeNode;18;-2044.512,590.9689;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;32;-2349.926,-189.4878;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;31;-2319.565,-388.9355;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;33;-2050.956,-608.7442;Float;False;Property;_Wavetiling;Wave tiling;12;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1770.153,411.0246;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1059.155,739.3571;Float;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2027.566,-286.9355;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-1137.449,552.5103;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;21;-1774.322,99.4932;Float;False;Property;_Alphatiling;Alpha tiling;1;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-763.5531,636.4408;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1766.678,-475.4999;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;54;-920.2672,1060.668;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-1472.938,233.0361;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-515.2125,919.5133;Float;False;Property;_VGradientfalloff;VGradient falloff;2;0;Create;True;0;0;False;0;0;2.41;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;56;-568.0711,1107.34;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;36;-1400.412,-451.7023;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;40;-435.7363,633.03;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;14;-1098.264,234.8976;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinTimeNode;52;-555.4741,1245.042;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-86.97388,920.5609;Float;False;Property;_Minimumopacity;Minimum opacity;3;0;Create;True;0;0;False;0;0;0.059;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-289.8178,1128.137;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;47;-133.379,632.9221;Float;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-322.2048,1402.246;Float;False;Property;_Pulsepower;Pulse power;4;0;Create;True;0;0;False;0;0;1.14;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1027.98,-677.9818;Float;False;Property;_Waveintensity;Wave intensity;13;0;Create;True;0;0;False;0;1;2.55;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-703.0065,89.03034;Float;False;Property;_Maincolor;Main color;0;1;[HDR];Create;True;0;0;False;0;0,0.8490566,0.8111528,0;2.996078,0.6499323,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-764.4891,305.377;Float;True;Property;_Alpha;Alpha;7;0;Create;True;0;0;False;0;094f846ca2a7f914ea23ab361f958db7;094f846ca2a7f914ea23ab361f958db7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;27;-1118.471,-488.8605;Float;True;Property;_Wavetexture;Wave texture;11;0;Create;True;0;0;False;0;6a02d582da740d3419bcc57e545919b7;6a02d582da740d3419bcc57e545919b7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;48;263.8745,630.4084;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-358.1589,93.19016;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;5;-717.6592,-166.7579;Float;True;Property;_Alphawaved;Alphawaved;8;0;Create;True;0;0;True;0;f3ea5d9b6f545234ca770153b2cb1ace;f3ea5d9b6f545234ca770153b2cb1ace;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-620.6795,-579.0248;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;4.79579,1127.562;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-47.23907,91.65916;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.5019608,0.5019608,0.5019608,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;686.9493,322.8664;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-266.4633,-299.9846;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;59;209.8617,1125.845;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;1104.626,396.4521;Float;False;Property;_Opacityintensity;Opacity intensity;6;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;26;250.3345,-180.0695;Float;True;LinearDodge;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;60;399.6199,1101.459;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;75;1121.814,220.4401;Float;False;Property;_Alphaaffectsopacity;Alpha affects opacity;5;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;80;1446.274,300.6253;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;650.7167,38.37771;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;13;1641.665,-238.423;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Robo shaders/Force field;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;4;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;19;0
WireConnection;23;1;22;0
WireConnection;31;0;30;0
WireConnection;31;1;29;0
WireConnection;24;0;23;0
WireConnection;24;1;18;2
WireConnection;34;0;31;0
WireConnection;34;1;32;2
WireConnection;38;0;37;2
WireConnection;38;1;39;0
WireConnection;35;0;33;0
WireConnection;35;1;34;0
WireConnection;20;0;21;0
WireConnection;20;1;24;0
WireConnection;56;0;54;2
WireConnection;36;0;35;0
WireConnection;40;0;38;0
WireConnection;14;0;20;0
WireConnection;55;0;56;0
WireConnection;55;1;52;3
WireConnection;47;0;40;0
WireConnection;47;1;46;0
WireConnection;4;1;14;0
WireConnection;27;1;36;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;15;0;3;0
WireConnection;15;1;4;0
WireConnection;5;1;14;0
WireConnection;73;0;74;0
WireConnection;73;1;27;0
WireConnection;62;0;55;0
WireConnection;62;1;63;0
WireConnection;50;0;15;0
WireConnection;76;0;4;0
WireConnection;76;1;48;0
WireConnection;28;0;73;0
WireConnection;28;1;5;0
WireConnection;59;0;62;0
WireConnection;26;0;50;0
WireConnection;26;1;28;0
WireConnection;60;1;59;0
WireConnection;75;0;48;0
WireConnection;75;1;76;0
WireConnection;80;0;75;0
WireConnection;80;1;78;0
WireConnection;57;0;26;0
WireConnection;57;1;60;0
WireConnection;13;2;57;0
WireConnection;13;9;80;0
ASEEND*/
//CHKSM=96A5B1887BBC027DA7E9E4C2B56656CAB43CB5E3