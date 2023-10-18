using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    public void StartGameButton()
    {
        SceneManager.LoadScene("Map_1");
    }
    public void OptionButton()
    {
        // to do
    }
    public void QuitButton()
    {
        Application.Quit();
    }
    public void RestartButton()
    {
        SceneManager.LoadScene("MainMenu");
    }
}
