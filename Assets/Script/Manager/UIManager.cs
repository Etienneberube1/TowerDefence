using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;


public class UIManager : Singleton<UIManager>
{
    public event Action<float> OnHpChange;
    public event Action<float> OnGoldChange;
    public event Action<float> OnTimeChange;
    public event Action<int> OnWaveChange;
    public event Action<bool> OnUiChange;

    Animator animator;
    private void Start()
    {
        animator = GetComponentInChildren<Animator>();
        StartCoroutine(FadeOutCoroutine());
    }
    public void UpdateTurretUI(bool enableUI)
    {
        OnUiChange?.Invoke(enableUI);
    }
    public void ChangeHealth(float currentHp)
    {
        OnHpChange?.Invoke(currentHp);
    }
    public void changeGold(float currentGold)
    {
        OnGoldChange?.Invoke(currentGold);
    }
    public void ChangeWaveIndex(int currentWave)
    {
        OnWaveChange?.Invoke(currentWave);
    }
    public void ChangeTimer(float currentTimer)
    {
        OnTimeChange?.Invoke(currentTimer);
    }

    public void FadeIn()
    {
        StartCoroutine(FadeInCoroutine());
    }

    IEnumerator FadeInCoroutine()
    {
        animator.SetBool("fade_in", true);

        yield return new WaitForSeconds(1.3f);

        animator.SetBool("fade_in", false);

        StartCoroutine(FadeOutCoroutine());
    }

    IEnumerator FadeOutCoroutine()
    {
        animator.SetBool("fade_out", true);

        yield return new WaitForSeconds(1.3f);

        animator.SetBool("fade_out", false);

    }
}
