using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FootprintCanvas : MonoBehaviour
{
    [SerializeField] float _attenuationAmount = 0.98f;
    [SerializeField] Texture _defaultNormal = null;

    Renderer _renderer;
    Material _material;

    RenderTexture _footprintMainTexture;
    RenderTexture _footprintNormalTexture;
    Material _colorMaterial;
    Material _footprintMainMaterial;
    Material _footprintNormalMaterial;
    Material _footprintAttenuationMaterial;

    float _updateInterval;
    float _updateFrameCount;

    void Awake()
    {
        _colorMaterial = CreateMaterial("Unlit/Color");
        _footprintMainMaterial = CreateMaterial("Custom/FootprintMain");
        _footprintNormalMaterial = CreateMaterial("Custom/FootprintNormal");
        _footprintAttenuationMaterial = CreateMaterial("Custom/FootprintAttenuation");
    }

    void Start()
    {
        _updateFrameCount = 0;
        _updateInterval = 3;

        _renderer = GetComponent<Renderer>();
        if(_renderer == null)
        {
            Debug.LogError($"{nameof(Renderer)}コンポーネントの取得に失敗しました。");
            return;
        }

        _material = _renderer.material;
        if (_material == null)
        {
            Debug.LogError("_renderer.materialが存在しません。");
            return;
        }

        Texture baseTexture = _material.mainTexture;
        if (baseTexture == null)
        {
            Debug.LogError("_material.mainTextureが存在しません。");
            return;
        }

        // メインテクスチャ生成
        _footprintMainTexture = new RenderTexture(baseTexture.width, baseTexture.height, 0, RenderTextureFormat.R8);
        _colorMaterial.color = Color.black;
        Graphics.Blit(null, _footprintMainTexture, _colorMaterial);

        // 法線マップテクスチャ生成
        //Texture defaultNormal = Resources.Load<Texture>("Textures/normal_default.png");
        //_footprintNormalTexture = new RenderTexture(_defaultNormal.width, _defaultNormal.height, 0, RenderTextureFormat.ARGB32);
        //Graphics.Blit(_defaultNormal, _footprintNormalTexture);

        DebugImage.SetTexture(_footprintMainTexture);
    }

    void FixedUpdate()
    {
        _updateFrameCount++;
        if(_updateFrameCount < _updateInterval)
        {
            return;
        }
        _updateFrameCount = 0;

        var footprintMainTextureBuffer = RenderTexture.GetTemporary(_footprintMainTexture.descriptor);
        _footprintAttenuationMaterial.SetTexture("_BaseMap", _footprintMainTexture);
        _footprintAttenuationMaterial.SetFloat("_Amount", _attenuationAmount);
        Graphics.Blit(null, footprintMainTextureBuffer, _footprintAttenuationMaterial);
        Graphics.Blit(footprintMainTextureBuffer, _footprintMainTexture);
        RenderTexture.ReleaseTemporary(footprintMainTextureBuffer);
    }

    public void Paint(FootprintData data)
    {
        Debug.Log(data.texcoord);

        // メインデータ
        var footprintMainTextureBuffer = RenderTexture.GetTemporary(_footprintMainTexture.descriptor);
        _footprintMainMaterial.SetTexture("_BaseMap", _footprintMainTexture);
        _footprintMainMaterial.SetTexture("_BlendMap", data.texture);
        _footprintMainMaterial.SetFloat("_Scale", data.scale);
        _footprintMainMaterial.SetFloat("_Rotate", data.rotate);
        _footprintMainMaterial.SetVector("_Position", data.texcoord);
        Graphics.Blit(null, footprintMainTextureBuffer, _footprintMainMaterial);
        Graphics.Blit(footprintMainTextureBuffer, _footprintMainTexture);
        RenderTexture.ReleaseTemporary(footprintMainTextureBuffer);

        // 法線データ
        //var footprintNormalTextureBuffer = RenderTexture.GetTemporary(_footprintNormalTexture.descriptor);
        //_footprintNormalMaterial.SetTexture("_BaseMap", _footprintNormalTexture);
        //_footprintNormalMaterial.SetTexture("_MainMap", _footprintMainTexture);
        //if (data.normalTexture != null)
        //    _footprintNormalMaterial.SetTexture("_BlendMap", data.normalTexture);
        //_footprintNormalMaterial.SetFloat("_Scale", data.scale);
        //_footprintNormalMaterial.SetFloat("_Rotate", data.rotate);
        //_footprintNormalMaterial.SetVector("_Position", data.texcoord);
        //Graphics.Blit(null, footprintNormalTextureBuffer, _footprintNormalMaterial);
        //Graphics.Blit(footprintNormalTextureBuffer, _footprintNormalTexture);
        //RenderTexture.ReleaseTemporary(footprintNormalTextureBuffer);

        _material.SetTexture("_FootprintMap", _footprintMainTexture);
        //_material.SetTexture("_FootprintNormalMap", _footprintNormalTexture);
        _material.SetColor("_FootprintColor", data.color);
    }

    void OnDestroy()
    {
        if (_footprintMainTexture != null)
        {
            _footprintMainTexture.Release();
        }

        if (_footprintNormalTexture != null)
        {
            _footprintNormalTexture.Release();
        }
    }

    Material CreateMaterial(string shaderName)
    {
        Shader shader = Shader.Find(shaderName);
        if (shader == null)
        {
            Debug.LogError($"{shaderName}が存在しません。");
            return null;
        }
        return new Material(shader);
    }
}
