using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turret : MonoBehaviour
{
    [Header("Attributes")]
    [SerializeField] protected float _range = 15f;
    [SerializeField] protected float _fireRate = 1f;
    [SerializeField] protected float _turretDmg = 50f;
    [SerializeField] protected float _turnSpeed = 10f;
    [SerializeField] protected float _turretValue = 150f;
    public float GetTurretValue { get { return _turretValue; } }


    [Header("Unity Fields")]
    [SerializeField] protected GameObject _bulletPrefabs;
    [SerializeField] protected string _enemyTag = "Enemy";
    [SerializeField] protected Transform _towerHead;
    [SerializeField] protected Transform _firePoint;
    protected float _fireCountDown = 0f;
    protected Transform _target;


    protected Animator _animator;



    protected virtual void Start()
    {
        InvokeRepeating("UpdateTarget", 0f, 0.5f);
        _animator = GetComponent<Animator>();

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

        // rotate the head of the turret troward the target
        Vector3 dir = _target.position - transform.position;
        Quaternion lookRotation = Quaternion.LookRotation(dir);
        Vector3 rotation = Quaternion.Lerp(_towerHead.rotation, lookRotation, Time.deltaTime * _turnSpeed).eulerAngles;
        _towerHead.rotation = Quaternion.Euler(0f, rotation.y, 0f);

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
        GameObject[] enemies = GameObject.FindGameObjectsWithTag(_enemyTag);
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
}
