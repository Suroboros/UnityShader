using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMoveController : MonoBehaviour
{
    public float speed = 10;
    public float speedH = 2.0f;
    public float speedV = 2.0f;

    private float yaw = 0.0f;
    private float pitch = 0.0f;
    private Camera mainCamera = null;
    // Start is called before the first frame update
    void Start()
    {
        mainCamera = GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(1))
        {
            yaw = speedH * Input.GetAxis("Mouse X");
            pitch = -speedV * Input.GetAxis("Mouse Y");

            transform.eulerAngles += new Vector3(pitch, yaw, 0.0f);
        }

        if (Input.GetKey("w"))
        {
            transform.position += transform.forward * speed * Time.deltaTime;
        }
        if (Input.GetKey("s"))
        {
            transform.position -= transform.forward * speed * Time.deltaTime;
        }
        if (Input.GetKey("d"))
        {
            transform.position += transform.right * speed * Time.deltaTime;
        }
        if (Input.GetKey("a"))
        {
            transform.position -= transform.right * speed * Time.deltaTime;
        }
        if (Input.GetKey("e"))
        {
            transform.position += transform.up * speed * Time.deltaTime;
        }
        if (Input.GetKey("q"))
        {
            transform.position -= transform.up * speed * Time.deltaTime;
        }
        // float scroll = Input.GetAxis("Mouse ScrollWheel");
        // if(scroll != 0)
        // {
        //     mainCamera.fieldOfView = Mathf.Clamp(mainCamera.fieldOfView - scroll * 50, 0.1f, 60);
        // }
    }
}
