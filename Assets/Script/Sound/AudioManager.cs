using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : MonoBehaviour
{
    private static AudioManager m_Instance;
    public static AudioManager Instance => m_Instance;
    public enum EAudio
    {
        ClickSound,
        MoveSound,
        TutorialMoveSound,
        TypeWritterSound,
        BuildSoundEffect,
        UpgradeSoundEffect
    }


    [System.Serializable]
    public struct AudioInfo
    {
        public EAudio AudioType;
        public AudioClip Clip;
    }

    [SerializeField] private List<AudioInfo> m_AudioList;

    private Dictionary<EAudio, AudioInfo> m_AudioDictionnary;
    private AudioPool m_AudioPool;

    private void Awake()
    {
        m_AudioDictionnary = new Dictionary<EAudio, AudioInfo>();
        m_AudioPool = new AudioPool();
        if (m_Instance == null)
        {
            m_Instance = this;
            DontDestroyOnLoad(this);
        }
        else
        {
            Destroy(gameObject);
        }

        foreach (AudioInfo CurrentAudio in m_AudioList)
        {
            m_AudioDictionnary.Add(CurrentAudio.AudioType, CurrentAudio);
        }
    }

    public void PlaySFX(EAudio AudioType)
    {
        AudioInfo info = m_AudioDictionnary[AudioType];
        AudioSource source = m_AudioPool.GetAvailableObjectInPool();
        source.volume = 0.2f;
        source.clip = info.Clip;
        source.loop = false;
        source.Play();
    }
}



