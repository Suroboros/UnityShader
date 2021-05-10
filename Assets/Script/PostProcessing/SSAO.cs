using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SSAO : PostProcessingBase
{
    private Camera currentCamera = null;
    private List<Vector4> sampleKernelList = new List<Vector4>();

    [Range(0, 0.002f)]
    public float DepthBiasValue = 0.002f;
    [Range(0.010f, 1.0f)]
    public float SampleKernelRadius = 1.0f;
    [Range(4, 32)]
    public int SampleKernelCount = 16;
    [Range(0.0f, 5.0f)]
    public float AOStrength = 1.0f;
    [Range(0, 2)]
    public int DownSample = 0;

    [Range(1, 4)]
    public int BlurRadius = 1;
    [Range(0, 0.2f)]
    public float BilaterFilterStrength = 0.2f;

    public bool OnlyShowAO = false;

    public enum SSAOPassName
    {
        GenerateAO = 0,
        BilateralFilter = 1,
        Composite = 2,
    }

    private void OnEnable()
    {
        currentCamera = GetComponent<Camera>();
        currentCamera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void OnDisable()
    {
        currentCamera.depthTextureMode &= ~DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {
            GenerateAOSampleKernel();

            var aoRT = RenderTexture.GetTemporary(source.width >> DownSample, source.height >> DownSample, 0);

            _Material.SetMatrix("_InverseProjectionMatrix", currentCamera.projectionMatrix.inverse);
            _Material.SetFloat("_DepthBiasValue", DepthBiasValue);
            _Material.SetVectorArray("_SampleKernelArray", sampleKernelList.ToArray());
            _Material.SetFloat("_SampleKernelCount", sampleKernelList.Count);
            _Material.SetFloat("_AOStrength", AOStrength);
            _Material.SetFloat("_SampleKeneralRadius", SampleKernelRadius);
            Graphics.Blit(source, aoRT, _Material, (int)SSAOPassName.GenerateAO);

            var blurRT = RenderTexture.GetTemporary(source.width >> DownSample, source.height >> DownSample, 0);
            _Material.SetFloat("_BilaterFilterFactor", 1.0f - BilaterFilterStrength);

            _Material.SetVector("_BlurRadius", new Vector4(BlurRadius, 0, 0, 0));
            Graphics.Blit(aoRT, blurRT, _Material, (int)SSAOPassName.BilateralFilter);

            _Material.SetVector("_BlurRadius", new Vector4(0, BlurRadius, 0, 0));
            if (OnlyShowAO)
            {
                Graphics.Blit(blurRT, destination, _Material, (int)SSAOPassName.BilateralFilter);
            }
            else
            {
                Graphics.Blit(blurRT, aoRT, _Material, (int)SSAOPassName.BilateralFilter);
                _Material.SetTexture("_AOTex", aoRT);
                Graphics.Blit(source, destination, _Material, (int)SSAOPassName.Composite);
            }

            RenderTexture.ReleaseTemporary(aoRT);
            RenderTexture.ReleaseTemporary(blurRT);
        }
    }

    private void GenerateAOSampleKernel()
    {
        if (SampleKernelCount == sampleKernelList.Count)
            return;
        sampleKernelList.Clear();
        for (int i = 0; i < SampleKernelCount; i++)
        {
            var vec = new Vector4(Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f), Random.Range(0, 1.0f), 1.0f);
            vec.Normalize();
            var scale = (float)i / SampleKernelCount;
            // Make sure distribution to quadratic function
            scale = Mathf.Lerp(0.01f, 1.0f, scale * scale);
            vec *= scale;
            sampleKernelList.Add(vec);
        }
    }

}
