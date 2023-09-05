using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : Singleton<GameManager>
{
    [SerializeField] private float _currency = 0;
    [SerializeField] private float _currentHealth = 20;

    public void AddCurrency(float amount)
    {
        _currency += amount;
        UIManager.Instance.changeGold(amount);
    }

    public void ChangeHealth(float amount)
    {
        _currentHealth -= amount;
        UIManager.Instance.ChangeHealth(_currentHealth);
    }
}


