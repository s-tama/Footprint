using System;
using UnityEngine;

public class FootprintPainter : MonoBehaviour
{
    [SerializeField] FootprintData _footprintData;

    void Start()
    {
        Camera.main.forceIntoRenderTexture = true;
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                var target = hit.transform.GetComponent<FootprintCanvas>();
                if (target != null)
                {
                    _footprintData.texcoord = hit.textureCoord;
                    target.Paint(_footprintData);
                }
            }
        }
    }
}
