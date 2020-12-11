using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fade : MonoBehaviour
{
    private Material material;
    private float scale = 0.0f;
    private bool faded = false;
    // Start is called before the first frame update
    void Start()
    {
        material = this.transform.GetComponent<MeshRenderer>().material;
    }

    // Update is called once per frame
    void Update()
    {
        if (!faded) 
        {
            scale += 0.001f;
            material.SetFloat("_FadeScale", scale);
            if (scale >= 1.0f) 
            {
                faded = true;
            }
        }
        if (faded) 
        {
            scale -= 0.001f;
            material.SetFloat("_FadeScale", scale);
            if (scale <= 0.0f) 
            {
                faded = false;
            }
        }
    }
}
