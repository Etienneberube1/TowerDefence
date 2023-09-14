using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RocketTurret : Turret
{
    [Header("Rocket Attributes")]
    [SerializeField] private float _rocketLiftHeight = 10f; // How high the rocket should rise before targeting the enemy
    [SerializeField] private float _rocketLiftSpeed = 5f; // How fast the rocket should rise

    protected override void Shoot()
    {
        GameObject rocketGO = (GameObject)Instantiate(_bulletPrefabs, _firePoint.position, _firePoint.rotation);
        Rocket rocket = rocketGO.GetComponent<Rocket>();
        if (rocket != null)
        {
            rocket.Launch(_target, _firePoint, _rocketLiftHeight, _rocketLiftSpeed);
            rocket.GetStat(_rocketLiftHeight, _rocketLiftSpeed);
        }
    }
}
