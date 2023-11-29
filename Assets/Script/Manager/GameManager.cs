using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : Singleton<GameManager>
{
    [Header("Game Stats")]
    [SerializeField] private float _currency = 0;
    [SerializeField] private float _currentHealth = 0;
    [SerializeField] private float _currentTotalRating = 0;


    public event Action<float> OnEnemyKill; 
    
    private void Start()
    {
        HideCursor();   

        UIManager.Instance.ChangeHealth(_currentHealth);
        UIManager.Instance.changeGold(_currency);
    }

    private void Update()
    {
        if (_currentHealth <= 0) {
            SceneManager.LoadScene("GameOver_Scene");
        }    
    }

    public void HideCursor()
    {
        // Lock the cursor to the center of the screen
        Cursor.lockState = CursorLockMode.Locked;
        // Hide the cursor
        Cursor.visible = false;
    }
    public void ShowCursor() 
    {
        // Lock the cursor to the center of the screen
        Cursor.lockState = CursorLockMode.None;
        // Hide the cursor
        Cursor.visible = true;

    }


    public void GiveXP(float XP_amount)
    {
        OnEnemyKill?.Invoke(XP_amount);
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
    public float GetCurrentRating()
    {
        return _currentTotalRating;
    }
    public void RemoveHealth(float amount)
    {
        _currentHealth -= amount;
        UIManager.Instance.ChangeHealth(_currentHealth);
    }

    public void AddHealth(float amount)
    {
        _currentHealth += amount;
        UIManager.Instance.ChangeHealth(_currentHealth);
    }

}


