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

    private float _sampleTime = 0f;
    private QuadraticCurve _quadraticCurve;
    private Transform _target;

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




        if (_sampleTime >= 1f) {
            startExploding();
            Debug.Log("boom");

        }
        else
        {
            Debug.Log("counting");

            _sampleTime += Time.deltaTime * _speed;
            transform.position = _quadraticCurve.evaluate(_sampleTime);
            transform.forward = _quadraticCurve.evaluate(_sampleTime + 0.01f) - transform.position;
        }



    }
    private void startExploding()
    {
        Debug.Log("explode");
        ExplosionAoE(transform.position, _explosionRadius);

    }
    public void seek(Transform target, QuadraticCurve quadraticCurve)
    {
        _target = target;
        _quadraticCurve = quadraticCurve;
    }

    private void ExplosionAoE(Vector3 center, float radius)
    {
        Collider[] Colliders = Physics.OverlapSphere(center, radius);


        foreach (Collider collider in Colliders)
        {
            Debug.Log("collider");

            if (collider.CompareTag("Enemy"))
            {
                Debug.Log("as hit collider");
                HitTarget(collider.GetComponent<Enemy>());
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
        Debug.Log("hit taregt");
        Destroy(gameObject, 0.2f);
    }


}
