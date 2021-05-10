using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class PlanarReflection : MonoBehaviour {
    private GameObject reflectCameraObj = null;
    private Camera reflectCamera = null;
    private RenderTexture reflectRT = null;
    private Material reflectMaterial = null;
    private bool isReflectCameraRendering = false;

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    /// <summary>
    /// This function is called when the object becomes enabled and active.
    /// </summary>
    void OnEnable()
    {
        reflectCameraObj = new GameObject("Reflection Camera");
        reflectCamera = reflectCameraObj.AddComponent<Camera>();
        if(reflectCamera != null)
        {
            reflectCamera.targetTexture = reflectRT;
            reflectCamera.enabled = true;
        }
    }

    /// <summary>
    /// This function is called when the behaviour becomes disabled or inactive.
    /// </summary>
    void OnDisable()
    {
        if(reflectCamera != null)
        {
            reflectCamera.targetTexture = null;
            reflectCamera.enabled = false;
            DestroyImmediate(reflectCamera);
            reflectCamera = null;
        }

        if (reflectCameraObj != null)
        {
            DestroyImmediate(reflectCameraObj);
            reflectCameraObj = null;
        }
        if (reflectRT != null)
        {
            RenderTexture.ReleaseTemporary(reflectRT);
            reflectRT = null;
        }

    }

	/// <summary>
	/// OnWillRenderObject is called for each camera if the object is visible.
	/// </summary>
	void OnWillRenderObject()
	{
        if(isReflectCameraRendering)
        {
            return;
        }

        isReflectCameraRendering = true;

        if(reflectCamera == null)
		{
            reflectCamera = reflectCameraObj.GetComponent<Camera>();
            //reflectCamera.CopyFrom(Camera.current);
        }

		if(reflectRT == null)
		{
            reflectRT = RenderTexture.GetTemporary(Camera.current.pixelWidth, Camera.current.pixelWidth, 24);
            //reflectRT = RenderTexture.GetTemporary(1024, 1024, 24);
        }

        // Synchronize camera
        SynchronizeCamera(Camera.current, reflectCamera);
        reflectCamera.targetTexture = reflectRT;
        reflectCamera.enabled = false;

        // Plan (Equation of a plane with normal)
        Vector3 normal = transform.up;
        float d = -Vector3.Dot(normal, transform.position);
        Vector4 plane = new Vector4(normal.x, normal.y, normal.z, d);
        
		// Calculate reflection matrix
        Matrix4x4 reflectMatrix = CalculateReflectionMaxtirx(normal, d);
        reflectCamera.worldToCameraMatrix = Camera.current.worldToCameraMatrix * reflectMatrix;

        // Oblique View Frustum Clippling
        var reflectViewMatrix = reflectCamera.worldToCameraMatrix.inverse.transpose * plane;
        var reflectProjectionMatrix = reflectCamera.CalculateObliqueMatrix(reflectViewMatrix);
        reflectCamera.projectionMatrix = reflectProjectionMatrix;

        GL.invertCulling = true;
        reflectCamera.Render();
        GL.invertCulling = false;

		if(reflectMaterial == null)
		{
            reflectMaterial = GetComponent<Renderer>().sharedMaterial;
        }
        reflectMaterial.SetTexture("_ReflectTexture", reflectRT);


        isReflectCameraRendering = false;

    }

	private void SynchronizeCamera(Camera srcCamera, Camera desCamera)
	{
		if(srcCamera != null && desCamera != null)
		{
            desCamera.clearFlags = srcCamera.clearFlags;
            desCamera.backgroundColor = srcCamera.backgroundColor;
            desCamera.farClipPlane = srcCamera.farClipPlane;
            desCamera.nearClipPlane = srcCamera.nearClipPlane;
            desCamera.orthographic = srcCamera.orthographic;
            desCamera.fieldOfView = srcCamera.fieldOfView;
            desCamera.aspect = srcCamera.aspect;
            desCamera.orthographicSize = srcCamera.orthographicSize;  
        }
	}

    private Matrix4x4 CalculateReflectionMaxtirx(Vector3 normal, float d)
	{
        Vector4 x = new Vector4(1 - 2 * normal.x * normal.x, -2 * normal.x * normal.y, -2 * normal.x * normal.z, -2 * d * normal.x);
        Vector4 y = new Vector4(-2 * normal.x * normal.y, 1 - 2 * normal.y * normal.y, -2 * normal.y * normal.z, -2 * d * normal.y);
        Vector4 z = new Vector4(-2 * normal.x * normal.z, -2 * normal.z * normal.y, 1 - 2 * normal.z * normal.z, -2 * d * normal.z);
        Vector4 w = new Vector4(0, 0, 0, 1);
        Matrix4x4 reflectM = new Matrix4x4();
        reflectM.SetRow(0, x);
        reflectM.SetRow(1, y);
        reflectM.SetRow(2, z);
        reflectM.SetRow(3, w);
        return reflectM;
    }

    public void SetRenderingFlag(bool flag)
    {
        isReflectCameraRendering = flag;
    }

}
