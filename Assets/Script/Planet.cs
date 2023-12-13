using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Planet : MonoBehaviour
{
    [SerializeField] private float _rotateSpeed = 10f;
    [SerializeField] private GameObject _planetToRotateAround;
    [SerializeField] private bool _canUp = false;
    [SerializeField] private bool _canLeft = false;
    private void Update()
    {
        RotateAroundSelf();
        RotateAroundPlanet();
    }

    private void RotateAroundSelf()
    {
        transform.Rotate(Vector3.left, _rotateSpeed * Time.deltaTime);
        transform.Rotate(Vector3.up, _rotateSpeed * Time.deltaTime);
    }

    private void RotateAroundPlanet()
    {
        if (_canUp)
        {
            transform.RotateAround(_planetToRotateAround.transform.position, Vector3.up, _rotateSpeed * Time.deltaTime);
        }
        if (_canLeft)
        {
            transform.RotateAround(_planetToRotateAround.transform.position, Vector3.left, _rotateSpeed / 2 * Time.deltaTime);
        }
        if (_canLeft && _canUp)
        {
            transform.RotateAround(_planetToRotateAround.transform.position, Vector3.left, _rotateSpeed / 2 * Time.deltaTime);
            transform.RotateAround(_planetToRotateAround.transform.position, Vector3.up, _rotateSpeed * Time.deltaTime);
        }
    }
}
