using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour {


    public GameObject player;

    private float offsetZ;

	// Use this for initialization
	void Start () {

        offsetZ = transform.position.z - player.transform.position.z;

	}

	// Update is called once per frame
	void Update () {

        // makes camera follow player
        transform.position = new Vector3(transform.position.x, transform.position.y, player.transform.position.z + offsetZ);

	}
}
