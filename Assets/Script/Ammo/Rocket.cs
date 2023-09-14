using System.Collections;
using UnityEngine;

public class Rocket : MonoBehaviour
{
    [Header("Rocket Parameters")]
    [SerializeField] private float _liftHeight = 10f;
    [SerializeField] private float _liftSpeed = 5f;
    [SerializeField] private float _rotationSpeed = 10f;
    [SerializeField] private float _moveSpeed = 10f;
    [SerializeField] private float _damage = 25f;
    [SerializeField] private GameObject _impactEffect;

    private Transform _target;
    private Vector3 initialDirection;
    void Update()
    {
        if (_target == null)
        {
            Destroy(gameObject);
            return;
        }
    }
    public void GetStat(float rocketLiftHeight, float rocketLiftSpeed) 
    {
        _liftHeight = rocketLiftHeight;
        _liftSpeed = rocketLiftSpeed;
    }
    public void Launch(Transform target, Transform launchDirection, float rocketLiftHeight, float rocketLiftSpeed)
    {
        _target = target;
        _liftHeight = rocketLiftHeight;
        _liftSpeed = rocketLiftSpeed;

        // Consider the cannon's forward direction
        initialDirection = launchDirection.forward;

        StartCoroutine(LiftOff());
    }

    private IEnumerator LiftOff()
    {
        // Adjust the target position based on both the liftHeight and initialDirection
        Vector3 liftTarget = transform.position + (Vector3.up + initialDirection) * _liftHeight;

        while (Vector3.Distance(transform.position, liftTarget) > 0.2f)
        {
            transform.position = Vector3.MoveTowards(transform.position, liftTarget, _liftSpeed * Time.deltaTime);
            yield return null;
        }

        StartCoroutine(RotateToTarget());
    }

    private IEnumerator RotateToTarget()
    {
        Quaternion startRotation = transform.rotation;
        Vector3 directionToTarget = (_target.position - transform.position).normalized;
        Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);

        float t = 0;

        while (t < 1)
        {
            t += Time.deltaTime * _rotationSpeed;
            transform.rotation = Quaternion.Slerp(startRotation, targetRotation, t);
            yield return null;
        }

        StartCoroutine(MoveToTarget());
    }

    private IEnumerator MoveToTarget()
    {
        while (Vector3.Distance(transform.position, _target.position) > 0.2f)
        {
            transform.position = Vector3.MoveTowards(transform.position, _target.position, _moveSpeed * Time.deltaTime);
            yield return null;
        }

        HitTarget();
    }
    private void HitTarget()
    {
        GameObject effect = Instantiate(_impactEffect, transform.position, transform.rotation);
        Destroy(effect, 2f);
        Enemy enemy = _target.GetComponent<Enemy>();
        enemy.TakeDamage(_damage);
        Destroy(gameObject);
    }
}
