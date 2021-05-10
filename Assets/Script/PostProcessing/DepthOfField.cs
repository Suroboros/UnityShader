using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthOfField : PostProcessingBase
{
    [Range(0.0f, 100.0f)]
    public float focalDistance = 10.0f;
    [Range(0.0f, 100.0f)]
    public float nearBlurScale = 0.0f;
    [Range(0.0f, 1000.0f)]
    public float farBlurScale = 50.0f;
    [Range(0, 6)]
    public int downSample = 1;
    [Range(0.0f, 20.0f)]
    public float samplerScale = 3.0f;
    [Range(0, 8)]
    public int blurIterations = 3;

    private Camera _mainCam = null;

    public Camera MainCam
    {
        get
        {
            if (_mainCam == null)
                _mainCam = GetComponent<Camera>();
            return _mainCam;
        }
    }

    void OnEnable()
    {
        // Enable generate depth texture
        MainCam.depthTextureMode |= DepthTextureMode.Depth;
    }
 
    void OnDisable()
    {
        // Disable generate depth texture
        MainCam.depthTextureMode &= ~DepthTextureMode.Depth;
    }
 
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_Material)
        {
 
            // Set a RT
            RenderTexture renderBuffer = RenderTexture.GetTemporary(src.width >> downSample, src.height >> downSample, 0, src.format);
            renderBuffer.filterMode = FilterMode.Bilinear;

            // Down sampler whith pass 0
            Graphics.Blit(src, renderBuffer, _Material, 0);

            float withFactor = 1.0f / ((1 << downSample) * 1.0f);
 
            for(int i = 0; i < blurIterations; i++)
            {
                float offSet = i * 1.0f;

                // Temp RT
                RenderTexture temp1 = RenderTexture.GetTemporary(src.width >> downSample, src.height >> downSample, 0, src.format);
                RenderTexture temp2 = RenderTexture.GetTemporary(src.width >> downSample, src.height >> downSample, 0, src.format);
 

                // Gaussian blur with pass 1(broadwise, endwise)
                _Material.SetVector("_offset", new Vector2(0, samplerScale * withFactor + offSet));
                Graphics.Blit(renderBuffer, temp1, _Material, 1);
                _Material.SetVector("_offset", new Vector2(samplerScale * withFactor + offSet, 0));
                Graphics.Blit(temp1, temp2, _Material, 1);

                RenderTexture.ReleaseTemporary(temp1);
                RenderTexture.ReleaseTemporary(renderBuffer);
                renderBuffer = temp2;
                
            } 
 
            // Set blur texture
            _Material.SetTexture("_BlurTex", renderBuffer);
            // Set focus
            _Material.SetFloat("_focalDistance", FocalDistanceToClipDepth(focalDistance));
            // Set near
            _Material.SetFloat("_nearBlurScale", nearBlurScale);
            // Set far
            _Material.SetFloat("_farBlurScale", farBlurScale);
 
            // Set clear texture with pass 2
            Graphics.Blit(src, dest, _Material, 2);
            // Release RT
            RenderTexture.ReleaseTemporary(renderBuffer);
        }
    }
 
    // Focus depth in clip view space
    private float FocalDistanceToClipDepth(float distance)
    {
        return MainCam.WorldToViewportPoint((distance - MainCam.nearClipPlane) * MainCam.transform.forward + MainCam.transform.position).z / (MainCam.farClipPlane - MainCam.nearClipPlane);
    }

}
