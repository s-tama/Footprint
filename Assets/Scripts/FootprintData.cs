using System;
using UnityEngine;

[Serializable]
public class FootprintData
{
    public Texture texture;
    public Texture normalTexture;
    public float scale;
    public float offsetRotate;
    [NonSerialized] public float rotate;
    public Color color;
    [NonSerialized] public Vector2 texcoord;
}
