using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IngameDebugConsole;
public class CheatSystem : MonoBehaviour
{
    private void Start()
    {
        DebugLogConsole.AddCommandInstance("GiveCurrency", "Will give the amount of currency specified", "GiveCurrency", this);
        DebugLogConsole.AddCommandInstance("GiveHealth", "Will give the amount of Health specified", "GiveHealth", this);

    }
    public void GiveCurrency(float amount)
    {
        GameManager.Instance.AddCurrency(amount);
    }

    public void GiveHealth(float amount)
    {
        GameManager.Instance.AddHealth(amount);
    }
}
