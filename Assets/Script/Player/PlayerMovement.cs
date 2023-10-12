using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] private float _maxMoveSpeed;
    [SerializeField] private Transform _orientation;
    [SerializeField] private float _accelerationSpeed = 5f; 
    [SerializeField] private float _decelerationSpeed = 5f;


    [Header("References")]
    [SerializeField] private Animator _animator;


    private float _currentMoveSpeed;
    private float _horizontalInput;
    private float _verticalInput;
    private Vector3 _moveDirection;
    private Rigidbody _rigidbody;

    
    private void Start()
    {
        _rigidbody = GetComponent<Rigidbody>();

        _rigidbody.freezeRotation = true;
        _currentMoveSpeed = 0f;
    }

    private void Update()
    {
        Inputs();
        MovePlayer();
    }

    private void Inputs()
    {
        _horizontalInput = Input.GetAxis("Horizontal");
        _verticalInput = Input.GetAxis("Vertical");
    }

    private void MovePlayer()
    {
        _moveDirection = _orientation.forward * _verticalInput + _orientation.right * _horizontalInput;

        if (_horizontalInput != 0 || _verticalInput != 0)
        {
            // Accelerate
            _currentMoveSpeed = Mathf.MoveTowards(_currentMoveSpeed, _maxMoveSpeed, _accelerationSpeed * Time.deltaTime);
            Vector3 desiredVelocity = _moveDirection.normalized * _currentMoveSpeed;
            _rigidbody.velocity = new Vector3(desiredVelocity.x, _rigidbody.velocity.y, desiredVelocity.z);
            _animator.SetInteger("AnimationPar", 1);
        }
        else
        {
            // Decelerate
            _currentMoveSpeed = Mathf.MoveTowards(_currentMoveSpeed, 0f, _decelerationSpeed * Time.deltaTime);
            Vector3 slowedVelocity = Vector3.MoveTowards(new Vector3(_rigidbody.velocity.x, 0, _rigidbody.velocity.z), Vector3.zero, _decelerationSpeed * Time.deltaTime);
            _rigidbody.velocity = new Vector3(slowedVelocity.x, _rigidbody.velocity.y, slowedVelocity.z);
            _animator.SetInteger("AnimationPar", 0);
        }
    }
}