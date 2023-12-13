using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioPool : MonoBehaviour
{
    private List<AudioSource> _pool = new List<AudioSource>();

    public AudioSource GetAvailableObjectInPool()
    {
        foreach (AudioSource CurrentAudio in _pool)
        {
            if (CurrentAudio != null)
            {
                if (!CurrentAudio.isPlaying)
                {
                    return CurrentAudio;
                }
            }
        }
        GameObject NewGameOjbect = new GameObject();
        AudioSource NewAudioSource = NewGameOjbect.AddComponent<AudioSource>();
        _pool.Add(NewAudioSource);
        return NewAudioSource;
    }
}