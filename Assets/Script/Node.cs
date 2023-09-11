using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Node : MonoBehaviour
{
    private bool _asTurretBeenSpawn = false;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            if (!_asTurretBeenSpawn)
            {
                UIManager.Instance.UpdateUI(true);
                GameManager.Instance.GetNodePosition(this.gameObject);
            }
        }
    }
    private void OnTriggerExit(Collider other)
    {
        // this will disable the Turret UI
        if (other.gameObject.CompareTag("Player"))
        {
            UIManager.Instance.UpdateUI(false);
        }
    }


    public void IsTurretPlace(bool _bool)
    {
        _asTurretBeenSpawn = _bool;
    }
}
