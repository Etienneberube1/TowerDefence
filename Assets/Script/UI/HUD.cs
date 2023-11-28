using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class HUD : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI _HPText;
    [SerializeField] private TextMeshProUGUI _GoldText;

    [SerializeField] private TextMeshProUGUI _WaveText;

    [SerializeField] private TextMeshProUGUI _TimerText;
    [SerializeField] private Toggle _ToggleWaveSend;

    private bool _toggleWaveSpawnBool = false;
    private void Awake()
    {
        UIManager.Instance.OnHpChange += OnHpChange;
        UIManager.Instance.OnTimeChange += OnTimerChange;
        UIManager.Instance.OnGoldChange += OnGoldChange;
        UIManager.Instance.OnWaveChange += OnWaveChange;
    }
    private void OnHpChange(float CurrentHP)
    {
        _HPText.text = ($"Life: {(CurrentHP)}");
    }
    private void OnWaveChange(int currentWave)
    {
        _WaveText.text = ($"Wave: {(currentWave)}");
    }
    private void OnTimerChange(float currentTime)
    {
        _TimerText.text = Mathf.Round(currentTime).ToString();
    }
    private void OnGoldChange(float currentCurrency)
    {
        _GoldText.text = ($"Gold: {(currentCurrency)}");
    }

    public void OnToggleWaveSend()
    {
        _toggleWaveSpawnBool = _ToggleWaveSend.isOn;
        UIManager.Instance.OnToggleWaveSend(_toggleWaveSpawnBool);
    }
    public void SendWave()
    {
        UIManager.Instance.SendWave();
    }



    private void OnDestroy()
    {
        UIManager.Instance.OnHpChange -= OnHpChange;
        UIManager.Instance.OnTimeChange -= OnTimerChange;
        UIManager.Instance.OnGoldChange -= OnGoldChange;
        UIManager.Instance.OnWaveChange -= OnWaveChange;
    }
}

