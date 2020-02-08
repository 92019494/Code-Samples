using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetObstacleColour : MonoBehaviour {

    private GameObject[] obstacles;
    private GameObject[] grounds;
    private bool groundAndObstaclesFound;
    private int changeObstacleColourCount;
    private int changeGroundColourCount;
    private int ranNumber;

    public List<Material> materials = new List<Material>();
    public Material obstacleMaterial;
    public Material groundMaterial;
    public Material groundMaterial2;
    public Material groundMaterial3;
    public Material groundMaterial4;
    public Material groundMaterial5;
    public Material groundMaterial6;
    public Material groundMaterial7;

    // This script changes the ground colour every time the level is loaded
    void Start () {

        materials.Add(groundMaterial);
        materials.Add(groundMaterial2);
        materials.Add(groundMaterial3);
        materials.Add(groundMaterial4);
        materials.Add(groundMaterial5);
        materials.Add(groundMaterial6);
        materials.Add(groundMaterial7);


        obstacles = GameObject.FindGameObjectsWithTag("Obstacle");
        grounds = GameObject.FindGameObjectsWithTag("Ground");
        groundAndObstaclesFound = false;

        foreach (GameObject obstacle in obstacles)
        {

            obstacle.GetComponent<Renderer>().material = obstacleMaterial;
        }

        ChangeGroundColour();
    }



    private void Update()
    {
        if (!groundAndObstaclesFound)
        {
            obstacles = GameObject.FindGameObjectsWithTag("Obstacle");
            grounds = GameObject.FindGameObjectsWithTag("Ground");
            groundAndObstaclesFound = true;

            foreach (GameObject obstacle in obstacles)
            {

                obstacle.GetComponent<Renderer>().material = obstacleMaterial;
            }
            ChangeGroundColour();

        }

       

    }

    private void ChangeGroundColour()
    {
        ranNumber = (int)Mathf.Floor(Random.Range(0, materials.Count));
        foreach (GameObject ground in grounds)
        {

            ground.GetComponent<Renderer>().material = materials[ranNumber];


        }
    }


 


}
