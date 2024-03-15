using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(RawImage))]
[ExecuteAlways]
public class DebugImage : MonoBehaviour
{
    static RawImage _rawImage;
    static bool _isEnabled;

    void Awake()
    {
        _rawImage = GetComponent<RawImage>();
        _rawImage.enabled = false;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            _rawImage.enabled = !_rawImage.enabled;
        }
    }

    void OnEnable()
    {
        _isEnabled = true;
    }

    void OnDisable()
    {
        _isEnabled = false;    
    }

    void OnDestroy()
    {
        _rawImage.enabled = true;
    }

    public static void SetTexture( Texture texture )
    {
        if (!_isEnabled) return;
        _rawImage.texture = texture;
    }
}
