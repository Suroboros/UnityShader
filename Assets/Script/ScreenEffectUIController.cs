using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ScreenEffectUIController : MonoBehaviour
{
    Toggle waveToggle = null;
    Toggle underWaterToggle = null;
    Toggle godRayToggle = null;
    Toggle dofToggle = null;

    GameObject dofSliderObj = null;

    GodRay_RaidalBlur godRayScript = null;
    ScreenDistortion screenDistortionScript = null;
    DepthOfField dofScript = null;
    // Start is called before the first frame update
    void Start()
    {
        waveToggle = GameObject.Find("Wave Effect Toggle").GetComponent<Toggle>();
        waveToggle.onValueChanged.AddListener(WaveEffectEnable);

        underWaterToggle = GameObject.Find("Under Water Effect Toggle").GetComponent<Toggle>();
        underWaterToggle.onValueChanged.AddListener(UnderWaterEffectEnable);

        godRayToggle = GameObject.Find("God Ray Toggle").GetComponent<Toggle>();
        godRayToggle.onValueChanged.AddListener(GodRayEnable);

        dofToggle = GameObject.Find("DOF Toggle").GetComponent<Toggle>();
        dofToggle.onValueChanged.AddListener(DOFEnable);

        godRayScript = GameObject.Find("Main Camera").GetComponent<GodRay_RaidalBlur>();
        screenDistortionScript = GameObject.Find("Main Camera").GetComponent<ScreenDistortion>();
        dofScript = GameObject.Find("Main Camera").GetComponent<DepthOfField>();
        dofSliderObj = GameObject.Find("DOF Slider");
        dofSliderObj.GetComponent<Slider>().onValueChanged.AddListener(ChangeFocus);
        dofSliderObj.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void WaveEffectEnable(bool isOn)
    {
        if(isOn)
        {
            screenDistortionScript.enabled = true;
            screenDistortionScript.SetWaveEnable(true);
        }
        else
        {
            screenDistortionScript.SetWaveEnable(false);
            screenDistortionScript.enabled = false;
        }

    }

    private void UnderWaterEffectEnable(bool isOn)
    {
        if (isOn)
        {
            screenDistortionScript.enabled = true;
            screenDistortionScript.SetUnderWaterEnable(true);
        }
        else
        {
            screenDistortionScript.SetUnderWaterEnable(false);
            screenDistortionScript.enabled = false;
        }

    }

    private void GodRayEnable(bool isOn)
    {
        if (isOn)
        {
            screenDistortionScript.enabled = false;
            godRayScript.enabled = true;
        }
        else
        {
            godRayScript.enabled = false;
        }

    }

    private void DOFEnable(bool isOn)
    {
        if (isOn)
        {
            screenDistortionScript.enabled = false;
            dofScript.enabled = true;
            dofSliderObj.SetActive(true);
        }
        else
        {
            dofScript.enabled = false;
            dofSliderObj.SetActive(false);
        }

    }

    private void ChangeFocus(float value)
    {
        if(dofScript != null)
        {
            dofScript.focalDistance = value;
        }
    }
}
