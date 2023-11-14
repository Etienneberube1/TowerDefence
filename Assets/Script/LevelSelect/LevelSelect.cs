using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelSelect : MonoBehaviour
{
    [SerializeField] private Level _levelSO;
    [SerializeField] private GameObject _infoPanel;
    [SerializeField] private GameObject _ParticleToSpawn;

    [SerializeField] private TextMeshProUGUI _levelName;

    [SerializeField] private TextMeshProUGUI _unlockRating;

    [SerializeField] private TextMeshProUGUI _currentlevelRating;

    [SerializeField] private TextMeshProUGUI _currentTotalRating;

    [SerializeField] private TextMeshProUGUI _neededRating;

    [SerializeField]private Animator _panelAnimator;

    private Transform _playerTransform;


    void Update()
    {
        if (_infoPanel.activeInHierarchy) {

            _levelName.text = _levelSO.mapName;

            _unlockRating.text = "Total rating to unclock : " + _levelSO.unlockRating.ToString();

            _currentlevelRating.text = "Current level Rating : " + _levelSO.currentRating.ToString();

            _currentTotalRating.text = "Current Total Rating : " + GameManager.Instance.GetCurrentRating().ToString();

            _neededRating.text = "Rating Needed : " + (_levelSO.unlockRating - GameManager.Instance.GetCurrentRating()).ToString();
        }
    }

    public void ClosePanelButton()
    {
        DisableCursor();
        _panelAnimator.SetBool("close", true);
        StartCoroutine(DisaleInfoPanel());
    }
    public void EnterLevel()
    {
        Debug.Log("entering map_" + _levelSO.mapIndex.ToString());

        StartCoroutine(LoadScene());
    }


    private IEnumerator LoadScene() {

        Instantiate(_ParticleToSpawn, _playerTransform.position, _playerTransform.rotation);
        _panelAnimator.SetBool("close", true);
        StartCoroutine(DisaleInfoPanel());

        // activate the fade in aniamtion to fadethe screen to black
        UIManager.Instance.FadeIn();

        yield return new WaitForSeconds(1.3f);

        SceneManager.LoadScene("map_" + _levelSO.mapIndex.ToString());

    }

    private void OnTriggerEnter(Collider other)
    {
        // turning on the info panel
        if (other.gameObject.CompareTag("Player"))
        {
            _playerTransform = other.transform;
            _infoPanel.SetActive(true);
            EnableCursor();
        }
    }

    private void OnCollisionExit(Collision collision)
    {

        // turning off the info panel
        if (collision.gameObject.CompareTag("Player"))
        {

             DisableCursor();

            _panelAnimator.SetBool("close", true);
            StartCoroutine(DisaleInfoPanel());
        }
    }


    private void EnableCursor()
    {
        // Lock the cursor to the center of the screen
        Cursor.lockState = CursorLockMode.None;
        // Hide the cursor
        Cursor.visible = true;
    }

    private void DisableCursor()
    {
        // Lock the cursor to the center of the screen
        Cursor.lockState = CursorLockMode.Locked;
        // Hide the cursor
        Cursor.visible = false;
    }

    private IEnumerator DisaleInfoPanel()
    {
        yield return new WaitForSeconds(1.0f);
        _infoPanel.SetActive(false);
    }
}
