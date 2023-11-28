using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UIElements;

public class WaveSpawner : MonoBehaviour
{
    [SerializeField] private Transform[] _enemyPrefabs;
    [SerializeField] private float _timeBetweenWaves = 5f;
    [SerializeField] private Transform _spawnPoint;
    [SerializeField] private float _countDown = 1;
    private int _waveIndex = 0;

    private bool _toggleWaveSend = false;

    private void Start()
    {
        UIManager.Instance.GiveWaveSpawnerRef(this);    
    }


    private void Update()
    {
        if (_toggleWaveSend)
        {
            if (_countDown <= 0f)
            {
                StartCoroutine(SpawnWave());
                _countDown = _timeBetweenWaves;
            }

            _countDown -= Time.deltaTime;
            UIManager.Instance.ChangeTimer(_countDown);
        }
    }
    public IEnumerator SpawnWave()
    {
        _waveIndex++;
        UIManager.Instance.ChangeWaveIndex(_waveIndex);

        for (int i = 0; i < _waveIndex; i++)
        {
            SpawnEnemy();
            yield return new WaitForSeconds(0.5f);
        }

    }

    private void SpawnEnemy()
    {
        int randomIndex = Random.Range(0, _enemyPrefabs.Length);
        Instantiate(_enemyPrefabs[randomIndex], _spawnPoint.position, _spawnPoint.rotation);
    }

    public void SetToggle(bool toggle)
    {
        _toggleWaveSend = toggle;
    }
}
