using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectionDepthNormal : PostProcessingBase
{
    public Color edgeColor = Color.black;
    public Color nonEdgeColor = Color.white;
    [Range(1, 5)]
    public int sampleRange = 1;
    [Range(0, 1.0f)]
    public float normalDiffThreshold = 0.2f;
    [Range(0, 5.0f)]
    public float depthDiffThreshold = 2.0f;

    private void Awake()
    {
       
    }

    private void OnEnable()
    {
        var cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void OnDisable()
    {
        var cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.None;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {
            _Material.SetColor("_EdgeColor", edgeColor);
            _Material.SetColor("_NonEdgeColor", nonEdgeColor);
            _Material.SetFloat("_SampleRange", sampleRange);
            _Material.SetFloat("_NormalDiffThreshold", normalDiffThreshold);
            _Material.SetFloat("_DepthDiffThreshold", depthDiffThreshold);
            Graphics.Blit(source, destination, _Material);
        }
    }

}
