using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class TransformSample : MonoBehaviour
{
    [SerializeField] Matrix4x4 _position;
    [SerializeField] Matrix4x4 _rotate;
    [SerializeField] Matrix4x4 _scale;

    void Update()
    {
        Vector3 pos = this.transform.position;
        Quaternion rotate = this.transform.rotation;
        Vector3 scale = this.transform.localScale;

        //this.transform.position = _position.MultiplyPoint(Vector3.zero);
        //this.transform.eulerAngles = _rotate.MultiplyPoint(Vector3.zero);
        this.transform.localScale = _scale.MultiplyPoint(new Vector3(0.5f, 0.5f, 0.5f));
    }
}
