using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Rocket : MonoBehaviour
{
    [SerializeField] private float _damage = 25f;
    [SerializeField] private float _speed = 5.0f;
    [SerializeField] private float _explosionRadius = 2.0f;
    [SerializeField] private GameObject _explosionEffect;

    private float _sampleTime = 0f;
    private QuadraticCurve _quadraticCurve;
    private Transform _target;
    private bool isSeeking = false;

    void Start()
    {
        _sampleTime = 0f;
    }

    void Update()
    {
        if (_target == null) {
            Destroy(gameObject);
            return;
        }


        if (isSeeking) startSeeking();

        _sampleTime += Time.deltaTime * _speed;
        transform.position = _quadraticCurve.evaluate(_sampleTime);
        transform.forward = _quadraticCurve.evaluate(_sampleTime + 0.001f) - transform.position;

        if (_sampleTime >= 1f) {
            isSeeking = true;
            _sampleTime = -500;
        }


    }
    private void startSeeking()
    {
        ExplosionAoE(transform.position, _explosionRadius);
        GameObject effect = Instantiate(_explosionEffect, transform.position, transform.rotation);
        Destroy(effect, 0.3f);

        isSeeking = false;
    }
    public void seek(Transform target, QuadraticCurve quadraticCurve)
    {
        _target = target;
        _quadraticCurve = quadraticCurve;
    }

    private void ExplosionAoE(Vector3 center, float radius)
    {
        Collider[] hitColliders = Physics.OverlapSphere(center, radius);


        foreach (var entityHit in hitColliders)
        {
            if (entityHit.GetComponent<Enemy>())
            {
                HitTarget(entityHit.GetComponent<Enemy>());
            }
        }
    }
    void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawSphere(transform.position, _explosionRadius);
    }
    private void HitTarget(Enemy enemy)
    {
        enemy.TakeDamage(_damage);
        Destroy(gameObject);
    }


}
