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

    void Update()
    {
        PlaceTurretOnMouseClick();
        if (Input.GetKeyDown(KeyCode.Tab)) {
            if (!_isTurretUiOn)
            {
                UIManager.Instance.UpdateTurretUI(true);
                _isTurretUiOn = true;
            } else {
                UIManager.Instance.UpdateTurretUI(false);
                _isTurretUiOn = false;
            }
            
        }

        if (Input.GetKeyDown(KeyCode.Q)) {
            _placingBasicTurret = true;
            ShowTurretPreview(0);
        }
        else if (Input.GetKeyDown(KeyCode.E)) {
            _placingRocketTurret = true;
            ShowTurretPreview(1);
        }
        else if (Input.GetKeyDown(KeyCode.R)) {
            _placingLaserTurret = true;
            ShowTurretPreview(2);
        }

        while (_placingBasicTurret)
        {
            ShowTurretPreview(0);
            return;
        }
        while (_placingRocketTurret)
        {
            ShowTurretPreview(1);
            return;
        }
        while (_placingLaserTurret)
        {
            ShowTurretPreview(2);
            return;
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

            Light turretLight = turretPreview.GetComponentInChildren<Light>();
            if (turretLight)
            {
                if (placeableLayerMask == (placeableLayerMask | (1 << hit.collider.gameObject.layer)))
                {
                    turretLight.color = validPlacementColor;
                }
                else
                {
                    turretLight.color = invalidPlacementColor;
                }
            }
        }
    }

    void PlaceTurretOnMouseClick()
    {
        if (Input.GetMouseButtonDown(0) && turretPreview != null)
        {
            Ray ray = _mainCam.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit, maxPlacementDistance, ~raycastIgnoreLayer) &&
                placeableLayerMask == (placeableLayerMask | (1 << hit.collider.gameObject.layer)))
            {
                _placingBasicTurret = false;
                _placingRocketTurret = false;
                _placingLaserTurret = false;

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

}
