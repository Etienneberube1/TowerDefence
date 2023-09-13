using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : Singleton<GameManager>
{
    [Header("Game Stats")]
    [SerializeField] private float _currency = 150;
    [SerializeField] private float _currentHealth = 20;
    private GameObject _currentNodeTransform = null;
    private Node _nodeScript;


    private void Start()
    {
        // Lock the cursor to the center of the screen
        Cursor.lockState = CursorLockMode.Locked;
        // Hide the cursor
        Cursor.visible = false;
    }
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

    public void GetNodePosition(GameObject node)
    {
        _currentNodeTransform = node;
        _nodeScript = node.GetComponent<Node>();
    }

    public void BaseTurretButton(GameObject turretPrefabs)
    {
        Turret turret = turretPrefabs.GetComponent<Turret>();
        float turretValue = turret._getTurretValue;
        if (_currency >= turretValue) {
            // spawn a turret at the node position using the prefab
            Instantiate(turretPrefabs, _currentNodeTransform.transform.position, _currentNodeTransform.transform.rotation);
            _currency -= turretValue;

            _nodeScript.IsTurretPlace(true);

            // turn off the turret ui
            UIManager.Instance.UpdateUI(false);
            UIManager.Instance.changeGold(_currency);
        }
    }
}


