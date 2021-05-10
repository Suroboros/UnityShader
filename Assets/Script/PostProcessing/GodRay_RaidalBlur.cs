using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GodRay_RaidalBlur : PostProcessingBase
{
    [Range(0.0f, 5.0f)][Tooltip("The range of GodRay")]
    public float godRayRange = 2.0f;
    public Color godRayColor = Color.yellow;
    [Tooltip("The threshold determine which color should be extracted")]
    public Color colorThreshold = Color.gray;
    [Range(1.0f, 4.0f)][Tooltip("The pow of luminance")]
    public float luminancePow = 3.0f;
    [Range(0.0f, 10.0f)][Tooltip("The distance between tow sampler in raidal blur")]
    public float raidalWeight = 1;
    [Range(1, 5)][Tooltip("The num of sample times in raidal blur")]
    public int raidalSampleRate = 3;
    [Range(1, 5)][Tooltip("The times of raidal blur")]
    public int raidalBlurRate = 2;
    [Range(0, 1)][Tooltip("The times of raidal blur")]
    public float depthThreshold = 0.8f;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnDisable()
    {
        GetComponent<Camera>().depthTextureMode &= ~DepthTextureMode.Depth;
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_Material)
        {
            RenderTexture renderBuffer = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);

            _Material.SetFloat("_GodRayRange", godRayRange);
            _Material.SetColor("_ColorThreshold", colorThreshold);
            _Material.SetFloat("_LuminancePow", luminancePow);
            _Material.SetFloat("_DepthThreshold", depthThreshold);
            Graphics.Blit(src, renderBuffer, _Material, 0);

            
            //Graphics.Blit(src, renderBuffer);

            for (int i = 0; i < raidalBlurRate; i++)
            {
                RenderTexture temp1 = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
                _Material.SetInt("_raidalSampleRate", raidalSampleRate);

                _Material.SetFloat("_raidalWeight", raidalWeight / src.width * (i * 2 + 1));
                Graphics.Blit(renderBuffer, temp1, _Material, 1);

                _Material.SetFloat("_raidalWeight", raidalWeight / src.width * (i * 2 + 2));
                Graphics.Blit(temp1, renderBuffer, _Material, 1);

                RenderTexture.ReleaseTemporary(temp1);
            }

            _Material.SetTexture("_BlurTex", renderBuffer);
            _Material.SetColor("_godRayColor", godRayColor);

            Graphics.Blit(src, dest, _Material, 2);
            RenderTexture.ReleaseTemporary(renderBuffer);
        }
    }
}
