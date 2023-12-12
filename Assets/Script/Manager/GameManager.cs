using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : Singleton<GameManager>
{
    public event Action<float> OnEnemyKill;

    [Header("Game Stats")]
    [SerializeField] private float _currency = 0;
    private float _currentCurrency = 0;
    [SerializeField] private float _health = 0;
    private float _currentHealth = 0;
    [SerializeField] private float _currentTotalRating = 0;



    private List<Enemy> activeEnemies = new List<Enemy>();


    public void RegisterEnemy(Enemy enemy)
    {
        if (!activeEnemies.Contains(enemy))
        {
            activeEnemies.Add(enemy);
        }
    }

    public void UnregisterEnemy(Enemy enemy)
    {
        activeEnemies.Remove(enemy);
    }

    public List<Enemy> GetActiveEnemies()
    {
        return activeEnemies;
    }





    private void Start()
    {
        HideCursor();

        _currentHealth = _health;
        _currentCurrency = _currency;

        UIManager.Instance.ChangeHealth(_currentHealth);
        UIManager.Instance.changeGold(_currentCurrency);
    }

    private void Update()
    {
        if (_currentHealth <= 0) {
            ShowCursor();
            // Check if the current active scene is not the GameOver scene
            if (SceneManager.GetActiveScene().name != "GameOver_Scene")
            {
                _currentHealth = _health;
                _currentCurrency = _currency;
                StartCoroutine(GameOverCoroutine());
            }
        }

        Debug.Log(_currentCurrency);
    }
    private IEnumerator GameOverCoroutine()
    {
        UIManager.Instance.FadeIn();


        yield return new WaitForSeconds(1f);

        SceneManager.LoadScene("GameOver_Scene");

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
        _currentCurrency += amount;
        UIManager.Instance.changeGold(_currentCurrency);

    }
    public void RemoveCurrency(float amount) 
    {
        _currentCurrency -= amount;

        UIManager.Instance.changeGold(_currentCurrency);
    }
    public float GetCurrency()
    {
        return _currentCurrency;
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


