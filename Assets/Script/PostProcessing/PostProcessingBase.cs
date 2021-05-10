using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
// Require camera
[RequireComponent(typeof(Camera))]
public class PostProcessingBase : MonoBehaviour
{
    public Shader shader = null;
    private Material _material = null;
    public Material _Material
    {
        get
        {
            if (_material == null)
            {
                _material = GenerateMaterial(shader);
            }
            return _material;
        }
    }

    // Generate material
    protected Material GenerateMaterial(Shader shader)
    {
        if (shader == null)
            return null;
        // Check if shader is supported
        if (shader.isSupported == false)
            return null;
        // Create material
        Material material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;
        if (material)
            return material;
        return null;
    }

}
