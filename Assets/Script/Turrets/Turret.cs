using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEditor;
public class Turret : MonoBehaviour
{
    //[Space(20)]
    //[Header("===============TURRET_STATS===============")]
    //[Space(20)]


    [SerializeField] private AnimationCurve _statGrowthCurve;
    [SerializeField] protected float _range = 0f; // Range of enemy detection
    [SerializeField] protected float _fireRate = 0f; // Speed at witch the turret fire
    [SerializeField] private float _minFireRate = 0f; // Minimum fire rate
    [SerializeField] protected float _damage = 0f; // turret dmg
    [SerializeField] protected float _turnSpeed = 0f; // Speed at witch the turret head turn
    [SerializeField] protected float _value = 0f; // Price of the turret
    [SerializeField] protected float _bulletSpeed = 5.0f; // Speed of the bullet
    [SerializeField] private int _currentLevel = 0; // Current level of the turret
    [SerializeField] private float _xpToNextLevel = 0f; // Initial XP required to reach the next level
    [SerializeField] private int _maxLevel = 0; // the cap of the turret level

    protected float _currentXP = 0f;
    protected float _fireCountDown = 0f;
    protected float _currentTowerLevel;

    public float GetTurretValue { get { return _value; } }


    //[Space(20)]
    //[Header("=============================================")]
    //[Space(20)]






    //[Space(20)]
    //[Header("===============UNITY_FIELDS===============")]
    //[Space(20)]


    [SerializeField] protected GameObject _bulletPrefabs;
    [SerializeField] protected Transform _towerHead;
    [SerializeField] protected GameObject _currentTurretVisual; // Current visual for the turret
    [SerializeField] private TextMeshProUGUI _levelText;
    [SerializeField] private Canvas _canvas;
    protected List<Transform> _firePoints = new List<Transform>();
    protected int _nextFirePointIndex = 0;

    //[Space(20)]
    //[Header("=============================================")]
    //[Space(20)]






    //[Space(20)]
    //[Header("===============OBJECT_LIST===============")]
    //[Space(20)]


    [SerializeField] protected List<GameObject> _turretsVisual = new List<GameObject>();
    private List<GameObject> _activeBullets = new List<GameObject>();


    //[Space(20)]
    //[Header("=============================================")]
    //[Space(20)]





    //[Space(20)]
    //[Header("===============PARTICLE_EFFECT===============")]
    //[Space(20)]

    [SerializeField] protected GameObject _spawnParticleEffect;


    //[Space(20)]
    //[Header("=============================================")]
    //[Space(20)]



    protected Transform _target;
    protected Animator _animator;
    private Camera _camera;





    protected void Awake()
    {
        GameManager.Instance.OnEnemyKill += GainXP;
    }


    protected void OnDestroy()
    {
        GameManager.Instance.OnEnemyKill -= GainXP;
    }

    private void LateUpdate()
    {
        _canvas.transform.LookAt(transform.position + _camera.transform.rotation * Vector3.forward, _camera.transform.rotation * Vector3.up);
    }

    protected virtual void Start()
    {
        _canvas.worldCamera = GameManager.Instance.GetCameraRef();
        _camera = GameManager.Instance.GetCameraRef();

        UpdateFirePoints(); // Initialize fire points
        UpdateTurretVisual(); // Set initial turret visual


        InvokeRepeating("UpdateTarget", 0f, 0.3f);
        _animator = GetComponent<Animator>();

        GameObject effect = Instantiate(_spawnParticleEffect, transform.position, _spawnParticleEffect.transform.rotation);
        Destroy(effect, 0.5f);
    }


    protected virtual void Update()
    {
        if (_target == null)
            return;

        UpdateShoot();

        // rotate the head of the turret troward the target
        Vector3 dir = _target.position - transform.position;
        Quaternion lookRotation = Quaternion.LookRotation(dir);
        Vector3 rotation = Quaternion.Lerp(_towerHead.rotation, lookRotation, Time.deltaTime * _turnSpeed).eulerAngles;
        _towerHead.rotation = Quaternion.Euler(0f, rotation.y, 0f);

    }

    private void UpdateFirePoints()
    {
        _firePoints.Clear(); // Clear the existing list
        if (_currentTurretVisual != null)
        {
            Debug.Log("Checking fire points in: " + _currentTurretVisual.name);
            AddFirePointsRecursive(_currentTurretVisual.transform);
            Debug.Log("Total fire points found: " + _firePoints.Count);
        }
        else
        {
            Debug.LogWarning("Current Turret Visual is null.");
        }
    }

    private void AddFirePointsRecursive(Transform parent)
    {
        foreach (Transform child in parent)
        {
            if (child.CompareTag("FirePoint"))
            {
                _firePoints.Add(child);
                Debug.Log("Added FirePoint: " + child.name);
            }

            // Recursively add fire points from all children
            if (child.childCount > 0)
            {
                AddFirePointsRecursive(child);
            }
        }
    }

    protected virtual void UpdateBullet(GameObject bullet, Transform target)
    {
        if (target == null)
        {
            Destroy(bullet);
            return;
        }

        Vector3 dir = target.position - bullet.transform.position;
        float distanceThisFrame = _bulletSpeed * Time.deltaTime;

        if (dir.magnitude <= distanceThisFrame)
        {
            BulletImpact(bullet, target);
            return;
        }
        bullet.transform.Translate(dir.normalized * distanceThisFrame, Space.World);
    }


    private void BulletImpact(GameObject bullet, Transform target)
    {
        //GameObject bulletEffect = Instantiate(_bulletImpactEffect, bullet.transform.position, bullet.transform.rotation);
        //Destroy(bulletEffect, 0.15f);

        Enemy enemy = target.GetComponent<Enemy>();
        if (enemy != null)
        {
            enemy.TakeDamage(_damage); // Make sure _damage is accessible here
            if (enemy._getEnemyHealth <= 0)
            {
                GainXP(enemy._xpAmount);
            }
        }
        Destroy(bullet);
    }

    public void ChangeAnimToIdle()
    {
        if (_animator != null)
        {
            _animator.SetTrigger("finishInstall");
        }
    }



    protected virtual void UpdateShoot()
    {
        if (_fireCountDown <= 0f)
        {
            GameObject bullet = Shoot();
            if (bullet != null)
                _activeBullets.Add(bullet);

            _fireCountDown = _fireRate;
        }
        _fireCountDown -= Time.deltaTime;


        for (int i = _activeBullets.Count - 1; i >= 0; i--)
        {
            if (_activeBullets[i] == null)
                _activeBullets.RemoveAt(i);
            else
                UpdateBullet(_activeBullets[i], _target);
        }
    }

    protected virtual GameObject Shoot()
    {
        // Check if there are any fire points available
        if (_firePoints.Count == 0)
        {
            Debug.LogWarning("No fire points available.");
            return null;
        }

        // Ensure the index is within the bounds of the list
        _nextFirePointIndex = _nextFirePointIndex % _firePoints.Count;

        Transform firePoint = _firePoints[_nextFirePointIndex];
        GameObject bulletGO = Instantiate(_bulletPrefabs, firePoint.position, firePoint.rotation);
       // _animator.SetTrigger("isFiring");

        // Prepare the index for the next fire point
        _nextFirePointIndex = (_nextFirePointIndex + 1) % _firePoints.Count;
        return bulletGO;
    }

    private void UpdateTarget()
    {
        float closestEnemyDistance = Mathf.Infinity;
        Enemy closestEnemy = null;

        foreach (Enemy enemy in GameManager.Instance.GetActiveEnemies())
        {
            float distanceToEnemy = Vector3.Distance(transform.position, enemy.transform.position);
            if (distanceToEnemy < closestEnemyDistance && distanceToEnemy <= _range)
            {
                closestEnemyDistance = distanceToEnemy;
                closestEnemy = enemy;
            }
        }

        _target = closestEnemy != null ? closestEnemy.transform : null;
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, _range);
    }


    protected void GainXP(float XP_amount)
    {
        _currentXP += XP_amount;
        while (_currentXP >= _xpToNextLevel && _currentLevel < _maxLevel)
        {
            _currentXP -= _xpToNextLevel;
            LevelUp();
        }
    }


    private void LevelUp()
    {
        _levelText.text = "Level: " + _currentLevel;
        _currentLevel++;
        _xpToNextLevel *= 1.2f;

        UpdateStats();
        UpdateTurretVisual();
    }


    private void UpdateStats()
    {
        float levelFactor = (float)_currentLevel / _maxLevel;

        // Increasing damage as the level goes up. 
        _damage = _damage + (levelFactor * _damage);

        // Decreasing fire rate (increasing delay between shots) as the level goes up.
        // This ensures that the fire rate doesn't go below a certain threshold.
        _fireRate = Mathf.Max(_fireRate - (levelFactor * _fireRate * 0.5f), _minFireRate);
    }

    protected virtual void UpdateTurretVisual()
    {
        if (_currentLevel % 5 == 1) // Change visual only at levels 1, 6, 11
        {
            int visualIndex = (_currentLevel - 1) / 5;
            if (visualIndex < _turretsVisual.Count)
            {
                GameObject newVisual = _turretsVisual[visualIndex];
                if (newVisual != null)
                {
                    if (_currentTurretVisual != null)
                    {
                        Destroy(_currentTurretVisual);

                        _currentTurretVisual = Instantiate(newVisual, transform.position , transform.rotation, transform);
                        UpdateFirePoints(); // Update fire points for the new visual
                        UpdateTowerHead(); // Update the tower head for the new visual

                        GameObject effect = Instantiate(_spawnParticleEffect, transform.position, _spawnParticleEffect.transform.rotation);
                        Destroy(effect, 0.5f);

                    }
                }
                else
                {
                    Debug.LogWarning($"Turret visual for level {_currentLevel} not found!");
                }
            }
        }
    }

    private void UpdateTowerHead()
    {
        if (_currentTurretVisual != null)
        {
            Transform foundTowerHead = _currentTurretVisual.transform.Find("TowerHead"); // Assuming "TowerHead" is the name
            if (foundTowerHead != null)
            {
                _towerHead = foundTowerHead;
            }
            else
            {
                Debug.LogError("Tower head not found in the current visual.");
            }
        }
        else
        {
            Debug.LogWarning("Current Turret Visual is null.");
        }
    }
}