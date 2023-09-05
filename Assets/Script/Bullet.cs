using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    private Transform _target;

    [SerializeField] private float _speed = 5f;
    [SerializeField] private float _damage = 25f;
    [SerializeField] private GameObject _impactEffect;

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

        Vector3 dir = _target.position - transform.position;
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
        GameObject effect = Instantiate(_impactEffect, transform.position, transform.rotation);
        Destroy(effect, 2f);
        Enemy enemy = _target.GetComponent<Enemy>();
        enemy.TakeDamage(_damage);
        Destroy(gameObject);
    }


    public void Seek(Transform target)
    {
        _target = target;
    }

}