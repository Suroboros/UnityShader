using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIControllerInGame : MonoBehaviour
{
    public string shaderValueName;
    Transform textTransform = null;
    Transform sliderTransform = null;
    Slider slider = null;
    Material material;
    // Start is called before the first frame update
    void Start()
    {
        textTransform = this.transform.Find("Canvas").transform.Find("Text").transform;
        sliderTransform = this.transform.Find("Canvas").transform.Find("Slider").transform;
        slider = this.transform.Find("Canvas").transform.Find("Slider").GetComponent<Slider>();
    }

    // Update is called once per frame
    void Update()
    {
        if(sliderTransform != null)
        {
            sliderTransform.rotation = Camera.main.transform.rotation;
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
        UnityEngine.Debug.Log(material);
        material.SetFloat(shaderValueName, slider.value);

    }
}
