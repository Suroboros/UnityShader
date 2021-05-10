using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ToggleGroupController : MonoBehaviour
{
    Toggle edgeDetectionToggle = null;
    Toggle edgeDetectionEffectToggle = null;
    Toggle SSAOToggle = null;

    EdgeDetection edgeDetectionScript = null;
    EdgeDetectionDepthNormal edgeDetectionDepthNormalScript = null;
    SSAO ssaoScript = null;

    GameObject depthSliderObj = null;
    GameObject normalSliderObj = null;
    GameObject effectFactorSliderObj = null;

    GameObject showAOOnlyToggleObj = null;

    // Start is called before the first frame update
    void Start()
    {
        edgeDetectionToggle = GameObject.Find("EdgeDetection").GetComponent<Toggle>();
        edgeDetectionToggle.onValueChanged.AddListener(EdgeDetectionEnable);

        edgeDetectionEffectToggle = GameObject.Find("EdgeDetectionEffect").GetComponent<Toggle>();
        edgeDetectionEffectToggle.onValueChanged.AddListener(EdgeDetectionEffectEnable);

        SSAOToggle = GameObject.Find("SSAO").GetComponent<Toggle>();
        SSAOToggle.onValueChanged.AddListener(SSAOEnable);

        edgeDetectionScript = GameObject.Find("Camera").GetComponent<EdgeDetection>();
        edgeDetectionDepthNormalScript = GameObject.Find("Camera").GetComponent<EdgeDetectionDepthNormal>();
        ssaoScript = GameObject.Find("Camera").GetComponent<SSAO>();

        depthSliderObj = GameObject.Find("Depth");
        var depthSlider = depthSliderObj.GetComponentInChildren<Slider>();
        depthSlider.minValue = 0.0f;
        depthSlider.maxValue = 5.0f;
        depthSlider.value = edgeDetectionDepthNormalScript.depthDiffThreshold;
        depthSlider.onValueChanged.AddListener(ChangeDepth);
        depthSliderObj.SetActive(false);

        normalSliderObj = GameObject.Find("Normal");
        var normalSlider = normalSliderObj.GetComponentInChildren<Slider>();
        normalSlider.minValue = 0.0f;
        normalSlider.maxValue = 1.0f;
        normalSlider.value = edgeDetectionDepthNormalScript.normalDiffThreshold;
        normalSlider.onValueChanged.AddListener(ChangeNormal);
        normalSliderObj.SetActive(false);

        effectFactorSliderObj = GameObject.Find("EffectFactorSlider");
        var effectFactorSlider = effectFactorSliderObj.GetComponent<Slider>();
        effectFactorSlider.minValue = 0.0f;
        effectFactorSlider.maxValue = 1.2f;
        effectFactorSlider.value = edgeDetectionScript.effectPercentage;
        effectFactorSlider.onValueChanged.AddListener(ChangeEffectFactor);
        effectFactorSliderObj.SetActive(false);

        showAOOnlyToggleObj = GameObject.Find("ShowAOOnlyToggle");
        showAOOnlyToggleObj.GetComponent<Toggle>().isOn = ssaoScript.OnlyShowAO;
        showAOOnlyToggleObj.GetComponent<Toggle>().onValueChanged.AddListener(ShowAOOnly);
        showAOOnlyToggleObj.SetActive(false);

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void EdgeDetectionEnable(bool isOn)
    {
        if (isOn)
        {
            depthSliderObj.SetActive(true);
            normalSliderObj.SetActive(true);
            edgeDetectionDepthNormalScript.enabled = true;
        }
        else
        {
            depthSliderObj.SetActive(false);
            normalSliderObj.SetActive(false);
            edgeDetectionDepthNormalScript.enabled = false;
        }

    }

    private void EdgeDetectionEffectEnable(bool isOn)
    {
        if (isOn)
        {
            effectFactorSliderObj.SetActive(true);
            edgeDetectionScript.enabled = true;
        }
        else
        {
            effectFactorSliderObj.SetActive(false);
            edgeDetectionScript.enabled = false;
        }

    }

    private void SSAOEnable(bool isOn)
    {
        if (isOn)
        {
            showAOOnlyToggleObj.SetActive(true);
            ssaoScript.enabled = true;
        }
        else
        {
            showAOOnlyToggleObj.SetActive(false);
            ssaoScript.enabled = false;
        }

    }

    private void ChangeDepth(float value)
    {
        if (edgeDetectionDepthNormalScript != null)
        {
            edgeDetectionDepthNormalScript.depthDiffThreshold = value;
        }
    }

    private void ChangeNormal(float value)
    {
        if (edgeDetectionDepthNormalScript != null)
        {
            edgeDetectionDepthNormalScript.normalDiffThreshold = value;
        }
    }

    private void ChangeEffectFactor(float value)
    {
        if (edgeDetectionScript != null)
        {
            edgeDetectionScript.effectPercentage = value;
        }
    }

    private void ShowAOOnly(bool isOn)
    {
        if (ssaoScript != null)
        {
            ssaoScript.OnlyShowAO = isOn;
        }
    }
}
