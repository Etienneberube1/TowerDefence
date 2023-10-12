using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThirdPersonCam : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Transform _orientation;
    [SerializeField] private Transform _player;
    [SerializeField] private Transform _playerObj;
    [SerializeField] private Rigidbody _playerRigidbody;

    [Header("Variables")]
    [SerializeField] private float _rotationSpeed;




    private void Update()
    {
        // rotate orientation
        Vector3 viewDir = _player.position - new Vector3(transform.position.x, _player.position.y, transform.position.z);
        _orientation.forward = viewDir.normalized;

        // rotate the object
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");
        Vector3 inputDir = _orientation.forward * verticalInput + _orientation.right * horizontalInput;

        if (inputDir != Vector3.zero) {
            _playerObj.forward = Vector3.Slerp(_playerObj.forward, inputDir.normalized, Time.deltaTime * _rotationSpeed);
        }
    }
}
