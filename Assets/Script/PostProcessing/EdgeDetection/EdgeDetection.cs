using UnityEngine;

[ExecuteInEditMode]
public class EdgeDetection : PostProcessingBase
{
    public enum EdgeOperator
    {
        Sobel = 0,
        Roberts = 1,
    }

    public Color edgeColor = Color.black;
    public Color nonEdgeColor = Color.white;
    [Range(1.0f, 10.0f)]
    public float edgePower = 1.0f;
    [Range(1, 5)]
    public int sampleRange = 1;
    [Range(0.0f, 5f)]
    public float effectPercentage = 0.5f;
    [Range(0.0f, 1.0f)]
    public float noiseFactor = 0.5f;

    public EdgeOperator edgeOperator = EdgeOperator.Sobel;
    public Texture flashTexture;
    public Texture noiseTexture;

    private void Awake()
    {

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {
            _Material.SetColor("_EdgeColor", edgeColor);
            _Material.SetColor("_NonEdgeColor", nonEdgeColor);
            _Material.SetFloat("_EdgePower", edgePower);
            _Material.SetFloat("_SampleRange", sampleRange);
            _Material.SetFloat("_EffectPercentage", effectPercentage);
            _Material.SetTexture("_FlashTexture", flashTexture);
            _Material.SetFloat("_NoiseFactor", noiseFactor);
            _Material.SetTexture("_NoiseTexture", noiseTexture);
            Graphics.Blit(source, destination, _Material, (int)edgeOperator);
        }
    }
}