using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Enemy : MonoBehaviour
{
    [SerializeField] private float _speed = 10;
    [SerializeField] private float _health = 50;
    [SerializeField] private float _GoldAmount = 150;
    [SerializeField] private float rotationSpeed = 5.0f;  
    private Transform _target;
    private int _wayPointIndex = 0;
    public float _getEnemyHealth { get { return _health; } }

    private void Start()
    {
        _target = WayPoints.Instance.points[0];
    }

    private void Update()
    {
        Movement();
    }


    private void Movement()
    {
        Vector3 dir = _target.position - transform.position;

        // Find the direction to the target and obtain the desired rotation
        Vector3 lookDirection = (_target.position - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(lookDirection);

        // Smoothly rotate towards the desired direction
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * rotationSpeed);

        // Continue with your movement logic
        transform.Translate(dir.normalized * _speed * Time.deltaTime, Space.World);

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
    }

    private void Dead()
    {
        GameManager.Instance.AddCurrency(_GoldAmount);
        Destroy(gameObject);
    }

    private void GetNextPoint()
    {
        if (_wayPointIndex >= WayPoints.Instance.points.Length - 1)
        {
            // enemy has reached the end 
            // remove a life 
            GameManager.Instance.RemoveHealth(1);
            Destroy(gameObject);
            return;
        }
        _wayPointIndex++;
        _target = WayPoints.Instance.points[_wayPointIndex];
    }
}
