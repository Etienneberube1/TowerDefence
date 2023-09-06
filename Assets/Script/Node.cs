using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Node : MonoBehaviour
{


    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            UIManager.Instance.UpdateUI(true);
            GameManager.Instance.GetNodePosition(this.transform);
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
}
