using UnityEngine;
using UnityEngine.UI;

public class LogWindow : MonoBehaviour
{
    [SerializeField] RectTransform _rectTransform = null;
    [SerializeField] LogWindowTopBar _topBar = null;
    [SerializeField] Button _exitButton = null;
    [SerializeField] Button _resizeButton = null;
    [SerializeField] Button _clearButton = null;
    [SerializeField] RectTransform _content = null;
    [SerializeField] Text _text = null;

    string _log;
    bool _isMaximized;
    Vector2 _defaultSize;
    Vector2 _defaultPos;

    public void Init()
    {
        _log = string.Empty;
        _isMaximized = false;
        _defaultSize = _rectTransform.sizeDelta;
        _defaultPos = _rectTransform.anchoredPosition;

        Application.logMessageReceived += (title, stacktrace, type) =>
        {
            switch (type)
            {
                case LogType.Error:
                case LogType.Assert:
                    LogError(title);
                    break;
                default:
                    Log(title);
                    break;
            }
        };

        _exitButton.onClick.AddListener(() =>
        {
            SetActive(false);
        });

        _resizeButton.onClick.AddListener(() =>
        {
            _isMaximized = !_isMaximized;
            Maximize(_isMaximized);
        });

        _clearButton.onClick.AddListener(() =>
        {
            ClearLog();
        });

        _topBar.onDrag = (eventData) =>
        {
            _rectTransform.anchoredPosition += eventData.delta;
        };
    }

    public void SetActive(bool value)
    {
        gameObject.SetActive(value);
    }

    void Log(string msg)
    {
        _log += msg + "\n";
        _text.text = _log;
        _content.sizeDelta = new Vector2(_content.sizeDelta.x, 40 * GetLength());
    }

    void LogError(string msg)
    {
        _log += $"<color=#ff0000>{msg}</color>\n";
        _text.text = _log;
        _content.sizeDelta = new Vector2(_content.sizeDelta.x, 40 * GetLength());
    }

    void ClearLog()
    {
        _log = string.Empty;
        _text.text = _log;
        _content.sizeDelta = new Vector2(_content.sizeDelta.x, 40);
    }

    int GetLength()
    {
        string[] logs = _log.Split('\n');
        return logs.Length;
    }

    void Maximize(bool isMaximized)
    {
        if (isMaximized)
        {
            _rectTransform.sizeDelta = new Vector2(Screen.width, Screen.height);
            _rectTransform.anchoredPosition = Vector2.zero;
        }
        else
        {
            _rectTransform.sizeDelta = _defaultSize;
            _rectTransform.anchoredPosition = _defaultPos;
        }
    }
}
