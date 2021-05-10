using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TextFocusCamera : MonoBehaviour
{
    Transform textTransform = null;
    // Start is called before the first frame update
    void Start()
    {
        textTransform = this.transform.Find("Canvas").transform.Find("Text").transform;
    }

    // Update is called once per frame
    void Update()
    {
        if(textTransform != null)
        {
            textTransform.rotation = Camera.main.transform.rotation;
        }
    }
}
