using UnityEngine;

public class DebugSystem : MonoBehaviour
{
    [SerializeField] LogWindow _logWindow = null;

#if !UNITY_EDITOR && (UNITY_IOS || UNITY_ANDROID)
        float _touchTime;
#endif

    void Awake()
    {
#if !UNITY_EDITOR && (UNITY_IOS || UNITY_ANDROID)
            _touchTime = 0f;
#endif
        _logWindow.Init();
    }

    void Update()
    {
#if UNITY_IOS || UNITY_ANDROID
        int touchCount = Input.touchCount;
        if (touchCount >= 3)
        {
            _touchTime += Time.deltaTime;
            if(_touchTime >= 1f)
            {
                _logWindow.SetActive(true);
            }
        }
        else
        {
            _touchTime = 0;
        }
#else
        if (Input.GetMouseButtonDown(1))
        {
            _logWindow.SetActive(true);
        }
#endif
    }
}
