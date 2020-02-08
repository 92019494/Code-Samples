using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AddLevelSection : MonoBehaviour {

    private int ranNumber;
    public GameObject levelSection1Prefab;
    public GameObject levelSection2Prefab;
    public GameObject levelSection3Prefab;
    public GameObject levelSection4Prefab;
    public GameObject levelSection5Prefab;
    public GameObject levelSection6Prefab;
    public GameObject levelSection7Prefab;
    public GameObject levelSection8Prefab;
    public GameObject levelSection9Prefab;
    public GameObject levelSection10Prefab;
    public GameObject levelSection11Prefab;
    public GameObject levelSection12Prefab;
    public GameObject levelSection13Prefab;
    public GameObject levelSection14Prefab;





    public ArrayList levelSections = new ArrayList();
	// Use this for initialization
	void Start () {

        levelSections.Add(levelSection1Prefab);
        levelSections.Add(levelSection2Prefab);
        levelSections.Add(levelSection3Prefab);
        levelSections.Add(levelSection4Prefab);
        levelSections.Add(levelSection5Prefab);
        levelSections.Add(levelSection6Prefab);
        levelSections.Add(levelSection7Prefab);
        levelSections.Add(levelSection8Prefab);
        levelSections.Add(levelSection9Prefab);
        levelSections.Add(levelSection10Prefab);
        levelSections.Add(levelSection11Prefab);
        levelSections.Add(levelSection12Prefab);
        levelSections.Add(levelSection13Prefab);
        levelSections.Add(levelSection14Prefab);




        ranNumber = (int)Mathf.Floor(Random.Range(0, levelSections.Count));
        int levelZIncrement = 0;

        // creates level when scene is started
        for (int i = 0; i < 300; i++)
        {

            ranNumber = (int)Mathf.Floor(Random.Range(0, levelSections.Count));
           // Debug.Log(ranNumber);
            Instantiate((GameObject)levelSections[ranNumber], new Vector3(0,0,levelZIncrement), this.transform.rotation);
            levelZIncrement += 400;

         
        }


    }
	

}
