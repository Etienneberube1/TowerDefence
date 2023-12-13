using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Enemy : MonoBehaviour
{
    [SerializeField] private float _speed = 10;
    [SerializeField] private float _health = 50;
    [SerializeField] private float _goldAmount = 150;
    [SerializeField] private float _rotationSpeed = 5.0f;
    [SerializeField] private float _xpAmountOnDeath = 20.0f;


    [SerializeField] private GameObject[] _itemToSpawn;
    private Transform _target;
    private int _wayPointIndex = 0;

    public float _getEnemyHealth { get { return _health; } }
    public float _xpAmount { get { return _xpAmountOnDeath; } }

    private void Start()
    {
        _target = WayPoints.Instance.points[0];
    }

    private void Update()
    {
        Movement();
    }

    public void SetHealth(float newHealth)
    {
        _health = newHealth;
    }
    private void Movement()
    {
        Vector3 dir = _target.position - transform.position;

        // Find the direction to the target and obtain the desired rotation
        Vector3 lookDirection = (_target.position - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(lookDirection);

        // Smoothly rotate towards the desired direction
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * _rotationSpeed);

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

        // Turn on emission
        SetEmission(true);

        // Turn off emission after 0.3 seconds
        StartCoroutine(ResetEmissionAfterDelay(0.1f));

        if (_health <= 0)
        {
            Dead();
        }
    }

    private IEnumerator ResetEmissionAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);
        SetEmission(false);
    }

    private void SetEmission(bool shouldEmit)
    {
        Renderer renderer = GetComponentInChildren<Renderer>(); // Assuming the Renderer is on a child GameObject
        if (renderer != null)
        {
            Material mat = renderer.material;
            if (mat != null)
            {
                if (shouldEmit)
                {
                    // Turn on emission
                    mat.EnableKeyword("_EMISSION");
                    mat.SetColor("_EmissionColor", Color.white); // Set the emission color to red, for example
                }
                else
                {
                    // Turn off emission
                    mat.DisableKeyword("_EMISSION");
                }
            }
        }
    }

    private void Dead()
    {
        GameManager.Instance.AddCurrency(_goldAmount);
        Destroy(gameObject);
    }


    private void OnEnable()
    {
        GameManager.Instance.RegisterEnemy(this);
    }

    private void OnDisable()
    {
        GameManager.Instance.UnregisterEnemy(this);
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
