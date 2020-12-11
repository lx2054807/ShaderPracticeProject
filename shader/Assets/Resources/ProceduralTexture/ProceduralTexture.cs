using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class ProceduralTexture : MonoBehaviour
{
    public Material material;

    #region Material Properties
    private int m_textureWidth = 512;
    public int textureWidth 
    {
        get 
        {
            return m_textureWidth;
        }
        set 
        { 
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get
        {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    private Color m_circleColor = Color.yellow;
    public Color circleColor
    {
        get
        {
            return m_circleColor;
        }
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    private float m_blurFactor = 12.0f;
    public float blurFactor
    {
        get
        {
            return m_blurFactor;
        }
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }
    #endregion

    private Texture2D m_generatedTexture = null;
    // Start is called before the first frame update
    void Start()
    {
        if (material == null) { return; }
        _UpdateMaterial();
    }

    // Update is called once per frame
    void _UpdateMaterial()
    {
        if (material != null) 
        {
            m_generatedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex",m_generatedTexture);
        }
    }

    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);
        float circleInterval = textureWidth / 4.0f;
        float radius = textureWidth / 10.0f;
        float edgeBlur = 1.0f / blurFactor;

        for (int w = 0; w < textureWidth; w++) 
        {
            for (int h =0; h < textureWidth; h++) 
            {
                Color pixel = backgroundColor;
                for (int i =0; i< 3; i++) 
                {
                    for (int j =0; j<3; j++) 
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dis = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        Color color = Color.Lerp(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dis * edgeBlur));
                        pixel = Color.Lerp(pixel, color, color.a);
                    }
                    proceduralTexture.SetPixel(w, h, pixel);
                }
            }
        }
        proceduralTexture.Apply();
        return proceduralTexture;
    }
}
