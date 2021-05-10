using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FloorUIController : MonoBehaviour
{
    Toggle mirrorToggle = null;
    Toggle waterToggle = null;
    Material waterMaterial = null;
    Material mirrorMaterial = null;
    Renderer floorRenderer = null;
    PlanarReflection planarReflectionScript = null;

    // Start is called before the first frame update
    void Start()
    {
        mirrorToggle = GameObject.Find("Mirror Toggle").GetComponent<Toggle>();
        mirrorToggle.onValueChanged.AddListener(MirrorEnable);
        mirrorMaterial = Resources.Load<Material>("Mirror");
        planarReflectionScript = GameObject.Find("Plane").GetComponent<PlanarReflection>();

        waterToggle = GameObject.Find("Water Toggle").GetComponent<Toggle>();
        waterToggle.onValueChanged.AddListener(WaterEffectEnable);
        //waterMaterial = new Material(Shader.Find("Custom/Water"));
        waterMaterial = Resources.Load<Material>("Water");

        floorRenderer = GameObject.Find("Plane").GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void MirrorEnable(bool isOn)
    {
        if(isOn)
        {
            planarReflectionScript.enabled = true;
            floorRenderer.material = mirrorMaterial;
        }
        else
        {
            planarReflectionScript.enabled = false;
        }

    }

    private void WaterEffectEnable(bool isOn)
    {
        if(isOn)
        {
            floorRenderer.material = waterMaterial;
        }
        else
        {
            
        }

    }
}
