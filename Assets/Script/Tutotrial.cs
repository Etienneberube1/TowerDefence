using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro; // Namespace for TextMeshPro

public class Tutorial : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI _stepTexte; // TextMeshPro component
    [SerializeField] private GameObject _tutorialPanel;
    [SerializeField] private GameObject _flashPanel;
    [SerializeField] private GameObject _flashPanel2;
    [SerializeField] private GameObject _spark;
    [SerializeField] private List<StepInfo> _stepList;

    private Animator _animator;
    private Dictionary<EStep, StepInfo> _stepDictionary;
    private EStep _currentStep;
    private bool _hasPressedQ = false;

    private Coroutine _currentTypewriterCoroutine;

    public enum EStep
    {
        step_1,
        step_2,
        step_3,
        step_4,
        step_5,
        step_6
    }

    [System.Serializable]
    public struct StepInfo
    {
        public EStep step;
        public string stepText;
    }


    private void Awake()
    {
        _stepDictionary = new Dictionary<EStep, StepInfo>();
        foreach (StepInfo currentStep in _stepList)
        {
            _stepDictionary.Add(currentStep.step, currentStep);
        }

        _currentStep = EStep.step_1;

    }

    private void Start()
    {
        StartCoroutine(WaitForTutotialToStart());
        _animator = _tutorialPanel.GetComponent<Animator>();
    }

    private void Update()
    {
        CheckStepCompletion();

    }

    private IEnumerator WaitForTutotialToStart()
    {
        yield return new WaitForSeconds(1f);

        _tutorialPanel.SetActive(true);

        _animator.SetTrigger("openUI");

        yield return new WaitForSeconds(0.5f);

        AudioManager.Instance.PlaySFX(AudioManager.EAudio.TutorialMoveSound);

        yield return new WaitForSeconds(0.7f);

        DisplayStepTextWithTypewriterEffect(_currentStep); // Display the first step text
    }

    private void CheckStepCompletion()
    {
        switch (_currentStep)
        {
            case EStep.step_1:
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    AdvanceToNextStep();
                }
                break;

            case EStep.step_2:
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    AdvanceToNextStep();
                    _flashPanel.SetActive(true);
                }
                break;

            case EStep.step_3:
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    AdvanceToNextStep();
                    _flashPanel.SetActive(false);
                    _spark.SetActive(true);
                }
                break;

            case EStep.step_4:
                if (Input.GetKeyDown(KeyCode.Q))
                {
                    _hasPressedQ = true;
                }
                if (Input.GetKeyDown(KeyCode.Mouse0) && _hasPressedQ)
                {
                    _spark.SetActive(false);
                    _flashPanel2.SetActive(true);
                    AdvanceToNextStep();
                    break;
                }

                break;

            case EStep.step_5:
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    _flashPanel2.SetActive(false);
                    AdvanceToNextStep();
                }
                break;
            
            case EStep.step_6:
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    _animator.ResetTrigger("openUI");
                    _animator.SetTrigger("closeUI");
                    StartCoroutine(ClosePanelCoroutine());
                    _currentStep = EStep.step_1;
                }
                break;
        }
    }

    private IEnumerator ClosePanelCoroutine()
    {
        yield return new WaitForSeconds(0.1f);
        _tutorialPanel.SetActive(false);

    }

    private void AdvanceToNextStep()
    {
        _currentStep++; // Advance to the next step
        if (_stepDictionary.ContainsKey(_currentStep))
        {
            DisplayStepTextWithTypewriterEffect(_currentStep); // Display the next step with typewriter effect
        }
    }

    public void DisplayStepTextWithTypewriterEffect(EStep step)
    {
        string textToDisplay = GetStepText(step);

        if (_currentTypewriterCoroutine != null)
        {
            StopCoroutine(_currentTypewriterCoroutine); // Stop the current coroutine if it's running
        }

        _currentTypewriterCoroutine = StartCoroutine(TypeText(textToDisplay));
    }
    IEnumerator TypeText(string text)
    {
        _stepTexte.text = ""; // Clear existing text
        foreach (char c in text)
        {
            _stepTexte.text += c;

            AudioManager.Instance.PlaySFX(AudioManager.EAudio.TypeWritterSound);

            yield return new WaitForSeconds(0.03f); // Wait time between characters
        }
    }
    public string GetStepText(EStep step)
    {
        if (_stepDictionary.TryGetValue(step, out StepInfo info))
        {
            return info.stepText;
        }
        return "Step not found";
    }
}
