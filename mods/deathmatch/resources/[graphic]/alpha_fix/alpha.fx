#include "mta-helper.fx"


sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
	//-- Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);
    //-- Apply diffuse lighting
    float4 finalColor = texel * PS.Diffuse;
    return finalColor;
    //return float4(1,0,0,1);
}
technique worldfiff
{
 
    pass P0
    {
        
        AlphaTestEnable = true;
        AlphaBlendEnable = true;
        //AlphaFunc = GREATEREQUAL;
        AlphaRef = 1;
        Lighting = false;
        //SrcBlend = SrcAlpha;
        //DestBlend = One;
        //DepthBias = -0.0005;
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
   
 
   
}
