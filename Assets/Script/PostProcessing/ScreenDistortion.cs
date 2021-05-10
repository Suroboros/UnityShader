using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class ScreenDistortion : PostProcessingBase {
	[Range(0,1000)]
    public float offsetFactor = 1.0f;
    [Range(0, 100)]
    public float distortRatio = 1.0f;
    [Range(0, 100)]
    public float timeRatio = 1.0f;
    public float distortWidth = 0.3f;
    public float distortSpeed = 0.1f;
    private float startTime;

    private bool waterWaveFlag = false;
    private bool underWaterFlag = false;

    private Vector4 mousePos = new Vector4(0.5f, 0.5f, 0, 0);

    /// <summary>
    /// This function is called when the object becomes enabled and active.
    /// </summary>
    void OnEnable()
	{
    	startTime = Time.time;
    }
    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if(Input.GetMouseButtonDown(0))
		{
            mousePos = new Vector4(Input.mousePosition.x / Screen.width, Input.mousePosition.y / Screen.height, 0, 0);
            startTime = Time.time;
        }
		
	}

	/// <summary>
	/// OnRenderImage is called after all rendering is complete to render image.
	/// </summary>
	/// <param name="src">The source RenderTexture.</param>
	/// <param name="dest">The destination RenderTexture.</param>
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if(_Material)
		{
            // float curDistance = (Time.time - startTime) * distortSpeed;
            // _Material.SetFloat("_offsetFacotr", offsetFactor);
            // _Material.SetFloat("_distortRatio", distortRatio);
            // _Material.SetFloat("_distortWidth", distortWidth);
            // _Material.SetFloat("_timeRatio", _timeRatio);
            // _Material.SetFloat("_curDistance", curDistance);
            // _Material.SetVector("_mousePos", mousePos);
            // _Material.SetInt("_repeatRatio", repeatRatio);
            // Graphics.Blit(src, dest, _Material,1);

            if(waterWaveFlag)
            {
                float curDistance = (Time.time - startTime) * distortSpeed;
                _Material.SetFloat("_offsetFactor", offsetFactor);
                _Material.SetFloat("_distortRatio", distortRatio);
                _Material.SetFloat("_distortWidth", distortWidth);
                _Material.SetFloat("_timeRatio", timeRatio);
                _Material.SetFloat("_curDistance", curDistance);
                _Material.SetVector("_mousePos", mousePos);
                Graphics.Blit(src, dest, _Material, 0);
            }

            if (underWaterFlag)
            {
                _Material.SetFloat("_offsetFacotr", offsetFactor);
                _Material.SetFloat("_distortRatio", distortRatio);
                _Material.SetFloat("_timeRatio", timeRatio);
                Graphics.Blit(src, dest, _Material, 1);
            }
        }
	}

    public void SetWaveEnable(bool enable)
    {
        waterWaveFlag = enable;
        offsetFactor = 75;
        distortRatio = 5;
        distortWidth = 0.3f;
        timeRatio = 1.5f;
        distortSpeed = 1.5f;
    }

    public void SetUnderWaterEnable(bool enable)
    {
        underWaterFlag = enable;
        offsetFactor = 3;
        distortRatio = 1.5f;
        timeRatio = 30;
    }
}
