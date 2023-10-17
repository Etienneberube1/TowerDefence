using UnityEngine;

public class TurretPlacer : MonoBehaviour
{
    [SerializeField] private GameObject[] turretPrefab;
    [SerializeField] private LayerMask placeableLayerMask;
    [SerializeField] private LayerMask raycastIgnoreLayer;
    [SerializeField] private float maxPlacementDistance = 20f;
    [SerializeField] private Color validPlacementColor = Color.green;
    [SerializeField] private Color invalidPlacementColor = Color.red;
    [SerializeField] private Camera _mainCam;

    private GameObject turretPreview;
    private bool _placingBasicTurret = false;
    private bool _placingRocketTurret = false;
    private bool _placingLaserTurret = false;
    private bool _isTurretUiOn = false;
    private int _currentTurretIndex;

    void Update()
    {
        PlaceTurretOnMouseClick();

        if (Input.GetKeyDown(KeyCode.Tab))
        {
            UIManager.Instance.UpdateTurretUI(!_isTurretUiOn);
            _isTurretUiOn = !_isTurretUiOn;
        }

        if (Input.GetKeyDown(KeyCode.Q))
        {
            if (!_placingBasicTurret)
            {
                CancelPlacement();
                _placingBasicTurret = true;
                _currentTurretIndex = 0;
                ShowTurretPreview(0);
            }
            else
            {
                CancelPlacement();
            }
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            if (!_placingRocketTurret)
            {
                CancelPlacement();
                _placingRocketTurret = true;
                _currentTurretIndex = 1;
                ShowTurretPreview(1);
            }
            else
            {
                CancelPlacement();
            }
        }
        else if (Input.GetKeyDown(KeyCode.R))
        {
            if (!_placingLaserTurret)
            {
                CancelPlacement();
                _placingLaserTurret = true;
                _currentTurretIndex = 2;
                ShowTurretPreview(2);
            }
            else
            {
                CancelPlacement();
            }
        }


        // making sure that the cursor become visible when trying to place a turret 
        if (_placingBasicTurret || _placingRocketTurret || _placingLaserTurret)
        {
            // Lock the cursor to the center of the screen
            Cursor.lockState = CursorLockMode.None;
            // Hide the cursor
            Cursor.visible = true;



            ShowTurretPreview(_currentTurretIndex);
        }
        else
        {

            // Lock the cursor to the center of the screen
            Cursor.lockState = CursorLockMode.Locked;
            // Hide the cursor
            Cursor.visible = false;
        }
    }

    void ShowTurretPreview(int turretPrefabsIndex)
    {
        if (turretPreview == null)
        {
            turretPreview = Instantiate(turretPrefab[turretPrefabsIndex]);
        }

        Ray ray = _mainCam.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, maxPlacementDistance, ~raycastIgnoreLayer))
        {
            turretPreview.transform.position = hit.point;

            if (placeableLayerMask == (placeableLayerMask | (1 << hit.collider.gameObject.layer)))
            {
                Light turretLight = turretPreview.GetComponentInChildren<Light>();
                if (turretLight)
                {
                    turretLight.color = validPlacementColor;
                }
            }
            else
            {
                IndicateInvalidPlacement(turretPreview);
            }
        }
    }

    void PlaceTurret(int turretPrefabIndex, Vector3 position)
    {
        // getting the turret script to get the value later
        Turret currentTurret = turretPrefab[turretPrefabIndex].GetComponent<Turret>();


        if (turretPrefabIndex >= 0 && turretPrefabIndex < turretPrefab.Length)
        {
            GameObject newTurret = Instantiate(turretPrefab[turretPrefabIndex], position, Quaternion.identity);

            // Destroy the light component in the new turret
            Light newTurretLight = newTurret.GetComponentInChildren<Light>();
            if (newTurretLight)
            {
                Destroy(newTurretLight.gameObject);
            }

            GameManager.Instance.RemoveCurrency(currentTurret._getTurretValue);
            CancelPlacement();
        }
    }

    void IndicateInvalidPlacement(GameObject turretPreview)
    {
        Light turretLight = turretPreview.GetComponentInChildren<Light>();
        if (turretLight)
        {
            turretLight.color = invalidPlacementColor;
        }
    }

    void CancelPlacement()
    {
        _placingBasicTurret = false;
        _placingRocketTurret = false;
        _placingLaserTurret = false;

        if (turretPreview != null)
        {
            // Destroy the light component in the turret preview
            Light turretLight = turretPreview.GetComponentInChildren<Light>();
            if (turretLight)
            {
                Destroy(turretLight.gameObject);
            }

            // Now destroy the turret preview
            Destroy(turretPreview);
            turretPreview = null;
        }
    }

    void PlaceTurretOnMouseClick()
    {
        // getting the current currency 
        float currentCurrency = GameManager.Instance.GetCurrency();
        Debug.Log(currentCurrency);

        // getting the turret script to get the value later
        Turret currentTurret = turretPrefab[_currentTurretIndex].GetComponent<Turret>();

        if (currentCurrency >= currentTurret._getTurretValue)
        {

            if (Input.GetMouseButtonDown(0) && turretPreview != null)
            {
                Ray ray = _mainCam.ScreenPointToRay(Input.mousePosition);
                RaycastHit hit;
                if (Physics.Raycast(ray, out hit, maxPlacementDistance, ~raycastIgnoreLayer) &&
                    placeableLayerMask == (placeableLayerMask | (1 << hit.collider.gameObject.layer)))
                {
                    PlaceTurret(_currentTurretIndex, hit.point);

                    // Destroy the light component in the turret preview, not the entire turret
                    Light turretLight = turretPreview.GetComponentInChildren<Light>();
                    if (turretLight)
                    {
                        Destroy(turretLight.gameObject);
                    }

                    turretPreview = null;
                }
            }
        }
        else
        {
            Debug.Log("Not Enough currency");
        }
    }
}
