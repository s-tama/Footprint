using System;
using UnityEngine;

public class RaycastEvent
{
    public event Action<RaycastHit> onEnter = null;
    public event Action<RaycastHit> onExit = null;
    public event Action<RaycastHit> onStay = null;
    bool _isLastEntered;
    RaycastHit _lastHit;

    public RaycastEvent()
    {
        _isLastEntered = false;
    }

    public void Update(Ray ray, float maxDistance)
    {
        if (Physics.Raycast(ray, out RaycastHit hit, maxDistance))
        {
            if (_isLastEntered)
            {
                onStay?.Invoke(hit);
            }
            else
            {
                onEnter?.Invoke(hit);
            }
            _isLastEntered = true;
            _lastHit = hit;
        }
        else
        {
            if (_isLastEntered)
            {
                onExit?.Invoke(_lastHit);
            }
            _isLastEntered = false;
        }
    }
}
