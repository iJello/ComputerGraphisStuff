using UnityEngine;

public class TextScript2Tex : MonoBehaviour
{
    Material myMaterial;
    public float texture;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        Renderer renderer = GetComponent<Renderer>();

        // 2. Access the Material (this acts as the bridge to your Shader Graph)
        myMaterial = renderer.material;
    }

    // Update is called once per frame
    void Update()
    {
        myMaterial.SetFloat("_Change", texture);
    }
}
