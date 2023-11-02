using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class Level : ScriptableObject
{
    [SerializeField, Tooltip("mpaIndex is = to the level, EX: map_1 would be Level_1")] public int mapIndex;


    [SerializeField, Tooltip("Map name will be the name of the scene")] public string mapName;

    [SerializeField, Tooltip("UnlockRating is the number of star the player need to unlock the map/level")] public float unlockRating;
    
    [SerializeField, Tooltip("currentRating is the rating the user got on this level")] public float currentRating;

}
