using System;
using UnityEngine;
using UnityEngine.EventSystems;

public class LogWindowTopBar : MonoBehaviour, IDragHandler
{
    public Action<PointerEventData> onDrag;

    public void OnDrag(PointerEventData eventData)
    {
        onDrag?.Invoke(eventData);
    }
}
