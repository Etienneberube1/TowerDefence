using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : Singleton<GameManager>
{
    [Header("Game Stats")]
    [SerializeField] private float _currency = 150;
    [SerializeField] private float _currentHealth = 20;
    private Transform _currentNodeTransform = null;
    public void AddCurrency(float amount)
    {
        _currency += amount;
        UIManager.Instance.changeGold(_currency);
    }

    public void ChangeHealth(float amount)
    {
        _currentHealth -= amount;
        UIManager.Instance.ChangeHealth(_currentHealth);
    }
    public void GetNodePosition(Transform nodeTransform)
    {
        _currentNodeTransform = nodeTransform;
    }

    public void BaseTurretButton(GameObject turretPrefabs)
    {
        Turret turret = turretPrefabs.GetComponent<Turret>();
        float turretValue = turret._getTurretValue;
        if (_currency >= turretValue) {
            // spawn a turret at the node position using the prefab
            Instantiate(turretPrefabs, _currentNodeTransform.position, _currentNodeTransform.rotation);
            _currency -= turretValue;
            // turn off the turret ui
            UIManager.Instance.UpdateUI(false);
            UIManager.Instance.changeGold(_currency);
        }
    }
}


