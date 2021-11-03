Shader "Custom/TextureSingle"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Tex2("Texture", 2D) = "white" {}
        _InvertirColor("InvertirColor", Range(0,  1)) = 0.0
        _Angle("Angle", Range(0,  6.3)) = 0.0

    }
        SubShader
    {
        Tags { "RenderType" = "Transparent" }        Blend SrcAlpha OneMinusSrcAlpha        Cull Off//para usar alpha

        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float light : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            float _InvertirColor;
            float _Angle;
            sampler2D _MainTex;
            sampler2D _Tex2;
            float4 _MainTex_ST;
            float4 _Tex2_ST;

            v2f vert(appdata v) {
                v2f o;
                //TILING
                o.pos = UnityObjectToClipPos(v.vertex);

                //TILING
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);//
                o.uv2 = TRANSFORM_TEX(v.uv, _Tex2);//

                //ROTACION
                float2 pivot = float2(0.5, 0.5);
                float cosAngle = cos(_Angle);
                float sinAngle = sin(_Angle);
                float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);

                float2 uv = v.uv - pivot;
                o.uv += mul(rot, uv);
                o.uv = o.uv + pivot;//

                //LUZ
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.light = max(0, dot(worldNormal, lightDir));//



                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 col1 = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_Tex2, i.uv2);

                //INVERTIR COLOR
                col1.rbg = abs((float3)_InvertirColor - col1.rbg);
                col2.rbg = abs((float3)_InvertirColor - col2.rbg);
                return col1*col2* i.light;
            }
            ENDCG
        }
    }
}