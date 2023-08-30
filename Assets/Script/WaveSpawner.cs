using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class WaveSpawner : MonoBehaviour
{
    [SerializeField] private Text _waveNumber;
    [SerializeField] private Text _timer;


    [SerializeField] private Transform _enemyPrefabs;
    [SerializeField] private float _timeBetweenWaves = 5f;
    [SerializeField] private Transform _spawnPoint;
    private float _countDown = 2;
    private int _waveIndex = 0;


    private void Update()
    {
        if (_countDown <= 0f)
        {
            StartCoroutine(SpawnWave());
            _countDown = _timeBetweenWaves;
        }

        _countDown -= Time.deltaTime;
        _timer.text = Mathf.Round(_countDown).ToString(); 
    }
    private IEnumerator SpawnWave()
    {
        _waveIndex++;
        _waveNumber.text = "Wave: " + _waveIndex;

        for (int i = 0; i < _waveIndex; i++)
        {
            SpawnEnemy();
            yield return new WaitForSeconds(0.5f);
        }

    }
    private void SpawnEnemy()
    {
        Instantiate(_enemyPrefabs, _spawnPoint.position, _spawnPoint.rotation);
    }

}
