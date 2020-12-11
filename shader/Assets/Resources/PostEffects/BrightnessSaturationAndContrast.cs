using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class ShaderProperty
{
    public static int brightness = Shader.PropertyToID("_Brightness");
    public static int saturation = Shader.PropertyToID("_Saturation");
    public static int contrast = Shader.PropertyToID("_Contrast");
}

public class BrightnessSaturationAndContrast : PostEffectsBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;
    public Material material { 
        get 
        { 
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        } 
    }

    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;

    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;

    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null) 
        {
            //material.SetFloat(Shader.PropertyToID("_Brightness"), brightness);
            //material.SetFloat(Shader.PropertyToID("_Saturation"), saturation);
            //material.SetFloat(Shader.PropertyToID("_Contrast"), contrast);
            //material.SetFloat(("_Brightness"), brightness);
            //material.SetFloat(("_Saturation"), saturation);
            //material.SetFloat(("_Contrast"), contrast);
            material.SetFloat(ShaderProperty.brightness, brightness);
            material.SetFloat(ShaderProperty.saturation, saturation);
            material.SetFloat(ShaderProperty.contrast, contrast);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
