using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : Singleton<GameManager>
{
    [Header("Game Stats")]
    [SerializeField] private float _currency = 0;
    [SerializeField] private float _currentHealth = 0;


    private void Start()
    {
        // Lock the cursor to the center of the screen
        Cursor.lockState = CursorLockMode.Locked;
        // Hide the cursor
        Cursor.visible = false;

        UIManager.Instance.ChangeHealth(_currentHealth);
        UIManager.Instance.changeGold(_currency);
    }
    public void AddCurrency(float amount)
    {
        _currency += amount;
        UIManager.Instance.changeGold(_currency);
    }
    public void RemoveCurrency(float amount) 
    {
        _currency -= amount;
        UIManager.Instance.changeGold(_currency);
    }
    public float GetCurrency()
    {
        return _currency;
    }
    public void ChangeHealth(float amount)
    {
        _currentHealth -= amount;
        UIManager.Instance.ChangeHealth(_currentHealth);
    }

}


