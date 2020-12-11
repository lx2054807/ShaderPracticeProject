using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class dissolve : MonoBehaviour
{
    private float scale;
    private Material material;
    // Start is called before the first frame update
    void Start()
    {
        //material = this.transform.GetComponent<SkinnedMeshRenderer>().material;
        material = this.transform.GetComponent<MeshRenderer>().material;
        material.SetFloat("_EdgeWidth", 0.01f);
    }

    // Update is called once per frame
    void Update()
    {
        scale += 0.001f;
        material.SetFloat("_Clip", scale);
    }
}
