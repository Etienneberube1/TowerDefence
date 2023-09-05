using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    [SerializeField] private float _speed = 10;
    [SerializeField] private float _health = 50;
    [SerializeField] private float _GoldAmount = 150;
    private Transform _target;
    private int _wayPointIndex = 0;

    private void Start()
    {
        _target = WayPoints._points[0];
    }

    private void Update()
    {
        Movement();
    }

    private void Movement()
    {
        Vector3 dir = _target.position - transform.position;
        transform.Translate(dir.normalized * _speed * Time.deltaTime);

        if (Vector3.Distance(transform.position, _target.position) <= 0.2f)
        {
            GetNextPoint();
        }
    }

    public void TakeDamage(float dmg)
    {
        _health -= dmg;
        if (_health <= 0)
        {
            Dead();
        }
        Debug.Log(_health);
    }


    private void Dead()
    {


        GameManager.Instance.AddCurrency(_GoldAmount);
        Destroy(gameObject);
    }
    private void GetNextPoint()
    {
        if (_wayPointIndex >= WayPoints._points.Length - 1)
        {
            // enemy as reach the end 
            // remove a life 
            GameManager.Instance.ChangeHealth(1);
            Destroy(gameObject);
            return;
        }
        _wayPointIndex++;
        _target = WayPoints._points[_wayPointIndex];
    }
}
