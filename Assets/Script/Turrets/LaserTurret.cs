using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserTurret : Turret
{
    private LineRenderer _lineRenderer;
    [SerializeField] private GameObject _laserHitParticule;

    private void Awake()
    {
        _lineRenderer = GetComponent<LineRenderer>();
    }
    protected override void Update()
    {
        if (_target == null)
        {
            if (_lineRenderer.enabled)
            {
                _lineRenderer.enabled = false;
            }
            return;
        }
        LockOnTarget();
        LaserShoot();


        if (_lineRenderer.enabled)
        {
            if (_fireCountDown <= 0f)
            {
                Shoot();
                _fireCountDown = _fireRate;
            }
            _fireCountDown -= Time.deltaTime;
        }

    }
    private void LaserShoot()
    {
        if (!_lineRenderer.enabled)
        {
            _lineRenderer.enabled = true;
        }
        _lineRenderer.SetPosition(0, _firePoint.position);
        _lineRenderer.SetPosition(1, _target.position);
    }
    private void LockOnTarget()
    {

        // rotate the head of the turret troward the target
        Vector3 dir = _target.position - transform.position;
        Quaternion lookRotation = Quaternion.LookRotation(dir);
        Vector3 rotation = Quaternion.Lerp(_towerHead.rotation, lookRotation, Time.deltaTime * _turnSpeed).eulerAngles;
        _towerHead.rotation = Quaternion.Euler(0f, rotation.y, 0f);
    }


    protected override void Shoot()
    {
        if (_target != null)
        {
            Enemy enemy = _target.GetComponent<Enemy>();
            enemy.TakeDamage(_turretDmg);

            GameObject hitEffect = Instantiate(_laserHitParticule, _target.transform.position, _target.transform.rotation);
            Destroy(hitEffect, 1f);
        }
    }
}
