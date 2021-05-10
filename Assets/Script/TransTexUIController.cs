using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TransTexUIController : MonoBehaviour
{
    Transform textTransform = null;
    Transform rangeSliderTransform = null;
    Transform alphaSliderTransform = null;
    Slider rangeSlider = null;
    Slider alphaSlider = null;
    Material material;

    // Start is called before the first frame update
    void Start()
    {
        textTransform = this.transform.Find("Canvas").transform.Find("Text").transform;
        rangeSliderTransform = this.transform.Find("Canvas").transform.Find("Range Slider").transform;
        rangeSlider = this.transform.Find("Canvas").transform.Find("Range Slider").GetComponent<Slider>();
        alphaSliderTransform = this.transform.Find("Canvas").transform.Find("Alpha Slider").transform;
        alphaSlider = this.transform.Find("Canvas").transform.Find("Alpha Slider").GetComponent<Slider>();
    }

    // Update is called once per frame
    void Update()
    {
        if(rangeSliderTransform != null)
        {
            rangeSliderTransform.rotation = Camera.main.transform.rotation;
        }

        if(alphaSliderTransform != null)
        {
            alphaSliderTransform.rotation = Camera.main.transform.rotation;
        }

        if(textTransform != null)
        {
            textTransform.rotation = Camera.main.transform.rotation;
        }
    }

    void OnWillRenderObject()
    {
        if (material == null)
        {
            material = GetComponent<Renderer>().sharedMaterial;
        }
        material.SetFloat("_Range", rangeSlider.value);
        material.SetFloat("_Alpha", alphaSlider.value);
    }
}
