using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.UIElements;
using UnityEngine;


public class Turret : MonoBehaviour
{
    private enum TOWER_LEVEL
    {
        TOWER_LEVEL_1 = 0,
        TOWER_LEVEL_2 = 1,
        TOWER_LEVEL_3 = 2
    }

    
        [Header("===============TURRET_STATS===============")]
    [SerializeField] protected float _range = 0f;
    [SerializeField] protected float _fireRate = 0f;
    [SerializeField] protected float _damage = 0f;
    [SerializeField] protected float _turnSpeed = 0f;
    [SerializeField] protected float _value = 0f;
    [SerializeField] protected float _maxXpAmount = 0f;
    protected float _currentXP = 0f;
    protected float _fireCountDown = 0f;
    protected float _currentTowerLevel;
    
    
    public float GetTurretValue { get { return _value; } }


        [Header("===============UNITY_FIELDS===============")]
    [SerializeField] protected GameObject _bulletPrefabs;
    [SerializeField] protected Transform _towerHead;
    [SerializeField] protected Transform _firePoint;
    [SerializeField] protected GameObject _spawnParticleEffect;
    [SerializeField] protected TagField _enemyTag;
    [SerializeField] protected List<GameObject> _turretsVisual = new List<GameObject>();
    protected Transform _target;
    protected Animator _animator;
    protected Mesh _mesh;

    protected void Awake()
    {
        GameManager.Instance.OnEnemyKill += OnEnemyKill;
    }

    protected void OnDestroy()
    {
        GameManager.Instance.OnEnemyKill -= OnEnemyKill;
    }

    
    
    protected virtual void Start()
    {
        InvokeRepeating("UpdateTarget", 0f, 0.5f);
        _animator = GetComponent<Animator>();
        
        GameObject effect = Instantiate(_spawnParticleEffect, transform.position, _spawnParticleEffect.transform.rotation);
        Destroy(effect, 0.5f);
    }

    public void ChangeAnimToIdle()
    {
        if (_animator != null)
        {
            _animator.SetTrigger("finishInstall");
        }
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


    protected virtual void UpdateShoot()
    {
        
        if (_fireCountDown <= 0f)
        {
            Shoot();
            _fireCountDown = _fireRate;
        }
        _fireCountDown -= Time.deltaTime;
    }

    protected virtual void Shoot()
    {
        GameObject bulletGO = (GameObject)Instantiate(_bulletPrefabs, _firePoint.position, _firePoint.rotation);
        Bullet bullet = bulletGO.GetComponent<Bullet>();
        if (bullet != null)
        {
            bullet.Seek(_target);
        }

        _animator.SetTrigger("isFiring");
    }


    private void UpdateTarget()
    {
        GameObject[] enemies = GameObject.FindGameObjectsWithTag(_enemyTag.ToString());
        float closestEnemy = Mathf.Infinity;
        GameObject nearestEnemy = null;

        foreach (GameObject enemy in enemies)
        {
            float distanceToEnemy = Vector3.Distance(transform.position, enemy.transform.position);
            if (distanceToEnemy < closestEnemy)
            {
                closestEnemy = distanceToEnemy;
                nearestEnemy = enemy;
            }
        }

        if (nearestEnemy != null && closestEnemy <= _range)
        {
            _target = nearestEnemy.transform;
        }
        else 
        {
            _target = null;
        }
    }
    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, _range);
    }


    private void OnEnemyKill(float XP_amount)
    {
        // making sure the xp dosent go above the max XP
        if (_currentXP >= _maxXpAmount) return;
        
        _currentXP += XP_amount;
        CheckLevelUp();
    }

    private void CheckLevelUp()
    {
        
        
        
    }


    private void ChangeTurretVisual(TOWER_LEVEL towerLevel)
    {
        switch (towerLevel)
        {
            case TOWER_LEVEL.TOWER_LEVEL_1 :
                break;            
            case TOWER_LEVEL.TOWER_LEVEL_2 :
                break;            
            case TOWER_LEVEL.TOWER_LEVEL_3 :
                break;
            default:
                break;
            
        }
    }
}
