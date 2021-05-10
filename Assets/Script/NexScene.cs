using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class NexScene : MonoBehaviour
{
    Button button = null;
    // Start is called before the first frame update
    void Start()
    {
        button = GetComponent<Button>();
        button.onClick.AddListener(GoToNextScene);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void GoToNextScene()
    {
        SceneManager.LoadScene("Map_v1", LoadSceneMode.Single);
    }
}
