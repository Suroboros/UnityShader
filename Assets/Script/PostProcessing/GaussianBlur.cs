using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostProcessingBase
{
    [Range(0, 6)]
    public int downSample = 1;
    [Range(0.0f, 20.0f)]
    public float samplerScale = 3.0f;
    [Range(0, 8)]
    public int blurIterations = 3;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
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
            
            Graphics.Blit(renderBuffer, dest);
            RenderTexture.ReleaseTemporary(renderBuffer);
        }
    }
}
