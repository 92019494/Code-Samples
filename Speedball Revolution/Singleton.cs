
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Singleton<T> : MonoBehaviour where T : MonoBehaviour
{

    // Creates Singleton instance for any class that implements it
    private static T instance;

    public static T Instance
    {
        get
        {
            // check if instance is null
            if (instance == null)
            {
                // First try to find object already in scene
                instance = FindObjectOfType<T>();

                if (instance == null)
                {
                    // Couldn't find the singleton in the scene, so make one
                    GameObject singleton = new GameObject(typeof(T).Name);
                    instance = singleton.AddComponent<T>();
                }
            }

            return instance;
        }
    }

    public virtual void Awake()
    {
        if (instance == null)
        {
            instance = this as T;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }
}
