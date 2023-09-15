using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserTurret : Turret
{
    [SerializeField] private GameObject _laserPrefab;
    private GameObject _spawnLaser;
    private LineRenderer _lineRenderer;
    

    private void Awake()
    {
        _fireRate = 0.3f;
        _spawnLaser = Instantiate(_laserPrefab, _firePoint.position, _firePoint.rotation);
        _lineRenderer = _spawnLaser.GetComponentInChildren<LineRenderer>();
        DisableLaser();
    }
    protected override void Update()
    {
        if (_target == null)
        {
            return;
        }

        _lineRenderer.SetPosition(0, _firePoint.position);
        _lineRenderer.SetPosition(1, _target.position);

        // rotate the head of the turret troward the target
        Vector3 dir = _target.position - transform.position;
        Quaternion lookRotation = Quaternion.LookRotation(dir);
        Vector3 rotation = Quaternion.Lerp(_towerHead.rotation, lookRotation, Time.deltaTime * _turnSpeed).eulerAngles;
        _towerHead.rotation = Quaternion.Euler(0f, rotation.y, 0f);

        if (_fireCountDown <= 0f)
        {
            Shoot();
            _fireCountDown = 1f / _fireRate;
        }
        _fireCountDown -= Time.deltaTime;
}
private void EnableLaser()
    {
        _spawnLaser.SetActive(true);
    }
    private void DisableLaser()
    {
        _spawnLaser.SetActive(false);
    }

    protected override void Shoot()
    {
        if (_target != null)
        {
            EnableLaser();
            Enemy enemy = _target.GetComponent<Enemy>();
            while (enemy._getEnemyHealth >= 0)
            {
                enemy.TakeDamage(_turretDmg);
            }
        }
        else {
            DisableLaser();
        }
    }
}
