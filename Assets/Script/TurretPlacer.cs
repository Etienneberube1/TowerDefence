using UnityEngine;

public class TurretPlacer : MonoBehaviour
{
    [SerializeField] private GameObject turretPrefab;
    [SerializeField] private LayerMask placeableLayerMask;
    [SerializeField] private LayerMask raycastIgnoreLayer;
    [SerializeField] private float maxPlacementDistance = 20f;
    [SerializeField] private Color validPlacementColor = Color.green;
    [SerializeField] private Color invalidPlacementColor = Color.red;

    private Camera mainCamera;
    private GameObject turretPreview;
    private bool _placingTurret = false;

    private void Start()
    {
        mainCamera = Camera.main;
    }

    void Update()
    {
        PlaceTurretOnMouseClick();
        if (Input.GetKeyDown(KeyCode.Q))
        {
            _placingTurret = true;
        }
        while (_placingTurret)
        {
            ShowTurretPreview();
            return;
        }
    }

    void ShowTurretPreview()
    {
        if (turretPreview == null)
        {
            turretPreview = Instantiate(turretPrefab);
        }

        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
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
            Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit, maxPlacementDistance, ~raycastIgnoreLayer) &&
                placeableLayerMask == (placeableLayerMask | (1 << hit.collider.gameObject.layer)))
            {
                _placingTurret = false;

                // Destroy the light component in the turret preview, not the entire turret
                Light turretLight = turretPreview.GetComponentInChildren<Light>();
                if (turretLight)
                {
                    Destroy(turretLight.gameObject);  // Assuming the light is on a separate child GameObject
                }

                turretPreview = null;  // Reset the reference, but don't destroy the turret itself
            }
        }
    }

}
