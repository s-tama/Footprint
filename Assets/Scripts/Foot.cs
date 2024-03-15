using System;
using UnityEngine;

public class Foot : MonoBehaviour
{
    [SerializeField] FootprintData _footprintData;
    [SerializeField] Transform _root;
    [SerializeField] float _distance = 0.1f;
    RaycastEvent _raycastEvent;

    void Start()
    {
        _raycastEvent = new RaycastEvent();
        _raycastEvent.onEnter += (hit) =>
        {
            var target = hit.transform.GetComponent<FootprintCanvas>();
            if (target != null)
            {
                _footprintData.rotate = -_root.eulerAngles.y + _footprintData.offsetRotate;
                _footprintData.texcoord = hit.textureCoord;
                target.Paint(_footprintData);
            }
        };
    }

    void Update()
    {
        Ray ray = new Ray(this.transform.position, -this.transform.up);
        _raycastEvent.Update(ray, _distance);
        Debug.DrawRay(ray.origin, ray.direction * _distance, Color.red);
    }
}
