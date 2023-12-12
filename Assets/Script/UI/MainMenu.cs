using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;


public class MainMenu : MonoBehaviour
{
    [SerializeField] private float _speed = 5.0f;
    [SerializeField] private GameObject _cam;

    private float _sampleTime = 0f;
    private bool _hasStarted = false;


    private QuadraticCurve _quadraticCurve;
    private Animator _animator;

    private void Start()
    {
        _quadraticCurve = GetComponent<QuadraticCurve>();
        _animator = GetComponentInChildren<Animator>();  
    }
    private void Update()
    {
        if (_hasStarted)
        {

            _sampleTime += Time.deltaTime * _speed;
            _cam.transform.position = _quadraticCurve.evaluate(_sampleTime);
            _cam.transform.forward = _quadraticCurve.evaluate(_sampleTime + 0.01f) - transform.position;

        }
    }

    public void StartGameButton()
    {
        _animator.SetTrigger("moveText");
        StartCoroutine(startGameCoroutine());

    }

    private IEnumerator startGameCoroutine()
    {

        yield return new WaitForSeconds(1f);
        UIManager.Instance.FadeIn();

        _hasStarted = true;

        yield return new WaitForSeconds(1f);

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
