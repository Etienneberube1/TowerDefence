using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RocketTurret : Turret
{
    [Space(20)]
    [Header("===============ROCKET_TURRET_VALUE===============")]
    [Space(20)]

    [SerializeField] private float _explosionRadius;
    private float _sampleTime = 0f;

    [SerializeField] private QuadraticCurve _quadraticCurve;

    protected override void Start()
    {
        base.Start();
        UpdateCurveControlPoint(); // Initialize the curve control point
        _quadraticCurve.pointA = _firePoints[0];
    }
    protected override void Update()
    {
        base.Update();
    }

    protected override GameObject Shoot()
    {
        GameObject rocketGO = base.Shoot();

        _quadraticCurve.pointA = _firePoints[_nextFirePointIndex].transform;


        return rocketGO;
    }

    protected override void UpdateBullet(GameObject bullet, Transform target)
    {
        if (target == null)
        {
            Destroy(bullet);
            return;
        }

        _quadraticCurve.pointB = target;

        _sampleTime += Time.deltaTime * _bulletSpeed;
        bullet.transform.position = _quadraticCurve.evaluate(_sampleTime);
        bullet.transform.forward = _quadraticCurve.evaluate(_sampleTime + 0.01f) - transform.position;

        bullet.transform.LookAt(target);
        if (_sampleTime >= 1)
        {
            RocketImpact(bullet);
            _sampleTime = 0;
        }
    }

    private void RocketImpact(GameObject bullet)
    {
        ExplosionAoE(_target.transform.position, _explosionRadius, bullet);

    }

    private void ExplosionAoE(Vector3 center, float radius, GameObject bullet)
    {
        Collider[] hitColliders = Physics.OverlapSphere(center, radius);
        foreach (var hitCollider in hitColliders)
        {
            if (hitCollider.CompareTag("Enemy"))
            {
                Enemy enemy = hitCollider.GetComponent<Enemy>();
                if (enemy != null)
                {
                    enemy.TakeDamage(_damage);
                    Destroy(bullet);
                }
            }
        }

    }

    protected override void UpdateTurretVisual()
    {
        base.UpdateTurretVisual();
        UpdateCurveControlPoint();

    }
    public void UpdateCurveControlPoint()
    {
        if (_currentTurretVisual != null)
        {
            FindCurveControlPoint(_currentTurretVisual.transform);
        }
        else
        {
            Debug.LogError("Current Turret Visual is null.");
        }
    }

    private void FindCurveControlPoint(Transform parent)
    {
        foreach (Transform child in parent)
        {
            if (child.CompareTag("CurveControl"))
            {
                _quadraticCurve.curveControl = child; // Found the control point
            }

            if (child.childCount > 0)
            {
                FindCurveControlPoint(child);
            }
        }
    }
}