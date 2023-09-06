using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class HUD : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI _HPText;
    [SerializeField] private TextMeshProUGUI _GoldText;
    [SerializeField] private TextMeshProUGUI _TimerText;
    [SerializeField] private TextMeshProUGUI _WaveText;
    [SerializeField] private GameObject _turretUI;

    private void Awake()
    {
        UIManager.Instance.OnHpChange += OnHpChange;
        UIManager.Instance.OnTimeChange += OnTimerChange;
        UIManager.Instance.OnGoldChange += OnGoldChange;
        UIManager.Instance.OnWaveChange += OnWaveChange;
        UIManager.Instance.OnUiChange += OnUiChange;
    }

    private void OnUiChange(bool enableUI)
    {
        _turretUI.gameObject.SetActive(enableUI);
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




    private void OnDestroy()
    {
        UIManager.Instance.OnHpChange -= OnHpChange;
        UIManager.Instance.OnTimeChange -= OnTimerChange;
        UIManager.Instance.OnGoldChange -= OnGoldChange;
        UIManager.Instance.OnWaveChange -= OnWaveChange;
        UIManager.Instance.OnUiChange -= OnUiChange;
    }
}

