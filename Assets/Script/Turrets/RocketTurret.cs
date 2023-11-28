using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RocketTurret : Turret
{
    [SerializeField] protected GameObject _fireEffect;
    private QuadraticCurve _quadraticCurve;

    protected override void Start()
    {
        base.Start();
        _quadraticCurve = GetComponent<QuadraticCurve>();
    }
    protected override void Update()
    {
        base.Update();
        if ( _quadraticCurve != null && _target != null) {
            _quadraticCurve.pointB = _target;
        }
    }
    protected override void Shoot()
    {
        _animator.SetTrigger("isFiring");

        GameObject effect = Instantiate(_fireEffect, _firePoint.position, transform.rotation);
        Destroy(effect, 0.3f);

        GameObject rocketGO = (GameObject)Instantiate(_bulletPrefabs, _firePoint.position, _firePoint.rotation);
        Rocket rocket = rocketGO.GetComponent<Rocket>();

        if (rocket != null)
        {
            rocket.seek(_target, _quadraticCurve);
        }
    }
}
