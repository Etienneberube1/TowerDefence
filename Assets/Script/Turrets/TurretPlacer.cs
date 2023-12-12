using System.Collections.Generic;
using TMPro;
using Unity.Burst.CompilerServices;
using UnityEngine;

enum TURRET_INDEX
{
    BASE_TURRET = 0,
    ROCKET_TURRET = 1,
    LASER_TURRET = 2
}

public class TurretPlacer : MonoBehaviour
{


    [Header("turret Prefabs")]
    [SerializeField] private List<GameObject> _turretsPrefabs;

    [Header("Main Camera")]
    [SerializeField] private Camera _mainCamera;

    [Header("Attributes")]
    [SerializeField] private float _maxPlacementDistance = 20.0f;
    [SerializeField] private LayerMask _placableLayerMask;

    [SerializeField, Tooltip("Should be the player layer")] 
    private LayerMask _IgnoreLayerMask; 



    private GameObject _turretPreview;
    private bool _isPreviewingTurret = false;


    private TURRET_INDEX _CURRENT_TURRET_INDEX;


    private void Update()
    {
        CheckInput();
        if (_isPreviewingTurret) { ShowTurretPreview(); }

        // Check for cancel key
        if (Input.GetKeyDown(KeyCode.X) && _isPreviewingTurret)
        {
            CancelTurretPlacement();
        }
    }
    private void CancelTurretPlacement()
    {
        if (_turretPreview != null)
        {
            Destroy(_turretPreview);
            _turretPreview = null;
        }
        _isPreviewingTurret = false;
        GameManager.Instance.HideCursor();
    }

    private float GetCurrentTowerValue()
    {
        float currentTowerValue;

        currentTowerValue = _turretsPrefabs[(int)_CURRENT_TURRET_INDEX].GetComponent<Turret>().GetTurretValue;

        return currentTowerValue;
    }

    private void CheckTurretValue(TURRET_INDEX TURRET_INDEX)
    {
        if (GameManager.Instance.GetCurrency() >= GetCurrentTowerValue())
        {
            GameManager.Instance.ShowCursor();

            // Reset and create a new turret preview
            if (_turretPreview != null)
            {
                Destroy(_turretPreview);
            }
            _turretPreview = Instantiate(_turretsPrefabs[(int)TURRET_INDEX]);

            _CURRENT_TURRET_INDEX = TURRET_INDEX;
            _isPreviewingTurret = true;
        }
        else
        {
            // Display text for not enough money
        }
    }
    private void RemoveCurrency()
    {
        GameManager.Instance.RemoveCurrency(GetCurrentTowerValue());
    }


    private void CheckInput()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            CancelTurretPlacement();
            CheckTurretValue(TURRET_INDEX.BASE_TURRET);
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            CancelTurretPlacement();
            CheckTurretValue(TURRET_INDEX.ROCKET_TURRET);
        }
        else if (Input.GetKeyDown(KeyCode.R))
        {
            CancelTurretPlacement();
            CheckTurretValue(TURRET_INDEX.LASER_TURRET);
        }
    }


    private void ShowTurretPreview()
    {
        if (_turretPreview == null)
        {
            _turretPreview = Instantiate(_turretsPrefabs[(int)_CURRENT_TURRET_INDEX]);
        }

        Ray ray = _mainCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, _maxPlacementDistance, ~_IgnoreLayerMask))
        {
            bool isValidPlacement = CheckForValidPlacement(hit);

            // if the mouse button is being pressed and it's on a valid layer
            if (Input.GetMouseButton(0) && isValidPlacement)
            {
                // reseting the value 
                _isPreviewingTurret = false;

                // making sure the turret preview dosent stays
                Destroy(_turretPreview);
                _turretPreview = null;

                // creating a new turret 
                PlaceTurret(hit.transform);
            }
        }
    }


    private bool CheckForValidPlacement(RaycastHit hit)
    {
        _turretPreview.transform.position = hit.point;
        Renderer[] turretRenderers = _turretPreview.GetComponentsInChildren<MeshRenderer>();
        bool isValid = ((1 << hit.transform.gameObject.layer) & _placableLayerMask) != 0;

        Collider turretPreviewCollider = _turretPreview.GetComponent<Collider>();

        if (isValid)
        {
            Collider[] colliders = Physics.OverlapSphere(hit.point, 1);
            foreach(Collider collider in colliders)
            {
                if(collider.CompareTag("Turret"))
                {
                    if(collider != turretPreviewCollider)
                    {
                        isValid = false;
                        break;
                    }
                }
            }
        }


        foreach (Renderer renderer in turretRenderers)
        {
            foreach (Material mat in renderer.materials) // Iterate over all materials
            {
                mat.color = isValid ? Color.green : Color.red;
                mat.SetColor("_EmissionColor", isValid ? Color.green * 0.3f : Color.red * 0.3f); // Set emission color and reduce intensity
                mat.EnableKeyword("_EMISSION");
            }
        }

        return isValid;
    }


    private void PlaceTurret(Transform groundPos)
    {
        RemoveCurrency();
        GameManager.Instance.HideCursor();

        Vector3 turretYOffSet = new Vector3(0, 0.1f, 0);

        // Instantiate the turret GameObject
        GameObject turretObject = Instantiate(_turretsPrefabs[(int)_CURRENT_TURRET_INDEX], groundPos.position + turretYOffSet, groundPos.rotation);

        // Get the Turret component
        Turret turretComponent = turretObject.GetComponent<Turret>();

        if (turretComponent != null)
        {
            // Activate the turret script
            turretComponent.enabled = true;
            CancelTurretPlacement();
        }
        else
        {
            Debug.LogError("Turret component not found on the object");
        }
    }
}
