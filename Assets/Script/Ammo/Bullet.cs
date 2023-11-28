using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    private Transform _target;

    [SerializeField] private float _speed = 5f;
    [SerializeField] private float _damage = 25f;
    [SerializeField] private GameObject _bulletImpactEffect;

    void Start()
    {

    }

    void Update()
    {
        if (_target == null)
        {
            Destroy(gameObject);
            return;
        }

        Vector3 dir = _target.position - transform.position + new Vector3(0.0f, 0.5f, 0.0f);
        
        float distanceThisFrame = _speed * Time.deltaTime;

        if (dir.magnitude <= distanceThisFrame)
        {
            HitTarget();
            return;
        }
        transform.Translate(dir.normalized * distanceThisFrame, Space.World);
    }

    private void HitTarget()
    {
        GameObject bulletEffect = Instantiate(_bulletImpactEffect, transform.position, transform.rotation);
        Destroy(bulletEffect, 0.15f);

        Enemy enemy = _target.GetComponent<Enemy>();
        enemy.TakeDamage(_damage);
        Destroy(gameObject);
    }


    public void Seek(Transform target)
    {
        _target = target;
    }

}