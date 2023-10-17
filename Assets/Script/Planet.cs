using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Planet : MonoBehaviour
{
    [SerializeField] private float _rotateSpeed = 10f;
    private void Update()
    {
        transform.Rotate(Vector3.left, _rotateSpeed * Time.deltaTime);
        transform.Rotate(Vector3.up, _rotateSpeed * Time.deltaTime);
    }
}
