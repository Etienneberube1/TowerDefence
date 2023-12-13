using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
public class GamePauseMenu : MonoBehaviour
{
    [SerializeField] private GameObject _pauseMenu;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            _pauseMenu.SetActive(!_pauseMenu.activeSelf);
            GameManager.Instance.ShowCursor();
        }
    }

    public void Resume()
    {
        _pauseMenu.SetActive(!_pauseMenu.activeSelf);
    }

    public void Leave()
    {
        StartCoroutine(LeaveCoroutine());
    }


    private IEnumerator LeaveCoroutine()
    {
        UIManager.Instance.FadeIn();

        yield return new WaitForSeconds(1f);

        GameManager.Instance.ResetValue();
        SceneManager.LoadScene("MainMenu");

    }

}
