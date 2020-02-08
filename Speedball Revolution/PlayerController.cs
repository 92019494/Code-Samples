using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.CrossPlatformInput;

public class PlayerController : MonoBehaviour {

    public GameObject redFire;
    public GameObject blueFire;
    public GameObject orangeFire;
    public GameObject purpleFire;
    private int invulnerableCount;
    public GameObject player;
    public GameObject shield;
    private int playerPosition;
    public Rigidbody rb;
    public GameObject loseMenuUI;
    public GameObject pauseMenuUI;
    private Vector2 fingerDown;
    private Vector2 fingerUp;
    public float playerVelocity;
    public float jumpPower;
    


    public float swipeThreshold = 20f;


  
    // Use this for initialization
    void Start () {
        if (playerVelocity > 200)
        {
            playerVelocity = 80;
        }

        // starts player on a maxxed velocity
        if (playerVelocity > 100)
        {
            playerVelocity = 100;
        }

        GameManager.Instance.RewardVideoWatched = false;

        if (SkinManager.PlayerSkin != null)
        {
            this.GetComponent<Renderer>().material = SkinManager.PlayerSkin;
        }
        // making sure invulnerable is not turned off after 2 seconds if shield is picked up 
        invulnerableCount = 0;

        
        rb = player.GetComponent<Rigidbody>();
        GameManager.Instance.Score = 0;
        GameManager.Instance.SpeedMultiplier = 0;
        GameManager.Instance.Invulnerable = false;
        Physics.gravity = new Vector3(0,-500,0); // was - 500 ends -900

        // 5 lanes and 2 represents middle one
        playerPosition = 2;
        StartCoroutine(SpeedUpPlayer()); 
        StartCoroutine(IncrementScore());


    }
    private void FixedUpdate()
    {
        if (Time.timeSinceLevelLoad < 3) { }
        else
        {
            rb.velocity = new Vector3(0, 0, playerVelocity); // was 70 ends 170
        }
    }

    // Update is called once per frame
    void Update() {


       

        //changes player material color
        if (SkinManager.PlayerSkin != null)
        {
            this.GetComponent<Renderer>().material = SkinManager.PlayerSkin;
        }


        if (GameManager.Instance.Lives == 0)
        {
            gameObject.SetActive(false);
        }

        if (loseMenuUI.activeInHierarchy || pauseMenuUI.activeInHierarchy)
        {
            Time.timeScale = 0;
        } 
        else 
        {
            Time.timeScale = 1f;
            CheckPlayerPosition(); 
        }


        // waiting three seconds to let countdown script run
        if (Time.timeSinceLevelLoad < 3) { }

        else
        {
            DisplayFire();
            // pc input controls
            if (Input.GetKeyDown(KeyCode.LeftArrow) && playerPosition > 0 && !pauseMenuUI.activeInHierarchy && !loseMenuUI.activeInHierarchy)
            {

                player.transform.position -= new Vector3(GameManager.Instance.SideMovement, 0f, 0f);
                playerPosition--;

            }
            if (Input.GetKeyDown(KeyCode.RightArrow) && playerPosition < 4 && !pauseMenuUI.activeInHierarchy && !loseMenuUI.activeInHierarchy)
            {

                player.transform.position += new Vector3(GameManager.Instance.SideMovement, 0f, 0f);
                playerPosition++;

            }

            if ((Input.GetKeyDown(KeyCode.Space) && this.transform.position.y < 1.1)
            && !pauseMenuUI.activeInHierarchy && !loseMenuUI.activeInHierarchy)
            {

                rb.AddForce(0,jumpPower,0,ForceMode.Impulse);

            }

            // mobile input controls
            foreach (Touch touch in Input.touches)
            {
                if (touch.phase == TouchPhase.Began)
                {
                    if (touch.position.x < Screen.width / 2 && touch.position.y < Screen.height * 0.9)
                    {
                        MoveLeft();
                    }
                    else if (touch.position.x > Screen.width / 2  && touch.position.y < Screen.height * 0.9)
                    {
                        MoveRight();
                    }
                }
            }
        }
    }

    private void SpeedUp()
    {
        StartCoroutine(SpeedUpPlayer());
    }


    IEnumerator SpeedUpPlayer()
    {
        float speedIncrement = 6.6f;
        float speedWaitTime = 5f;

        //wait for countdown timer
        yield return new WaitForSeconds(3f);

        for (int i = 0; i < 15; i++) {
            if (!loseMenuUI.activeInHierarchy && playerVelocity < 165)
            {
                GameManager.Instance.SpeedMultiplier += 2;
                playerVelocity += speedIncrement;
                yield return new WaitForSeconds(speedWaitTime);

            }
        }

    }

    private void AddScore()
    {
        StartCoroutine(IncrementScore());
    }

    IEnumerator IncrementScore()
    {


        //wait for countdown timer
        yield return new WaitForSeconds(3f);

        for (int i = 0; i < 1000; i++)
        {
            if (!loseMenuUI.activeInHierarchy && !pauseMenuUI.activeInHierarchy)
            {
                GameManager.Instance.Score += 10 * GameManager.Instance.SpeedMultiplier;

                yield return new WaitForSeconds(.5f);
            }
        }

    }



    public void MakeInvulnerable()
    {
        StartCoroutine(MakeInvulnerableRoutine());
    }


    IEnumerator MakeInvulnerableRoutine()
    {
        // makes player invulnerable for x seconds
        Debug.Log("routine started");
        invulnerableCount++;
        GameManager.Instance.Invulnerable = true;
        shield.SetActive(true);

        yield return new WaitForSeconds(2f);
        invulnerableCount--;
        if (invulnerableCount <= 0)
        {
            GameManager.Instance.Invulnerable = false;
            shield.SetActive(false);

            Debug.Log("routine finished");
        }

    }

    void DisplayFire()
    {
        if (!gameObject.activeInHierarchy)
        {
            redFire.SetActive(false);
            orangeFire.SetActive(false);
            blueFire.SetActive(false);
            purpleFire.SetActive(false);
        }
        if (playerVelocity > 150)
        {
            redFire.SetActive(false);
            orangeFire.SetActive(false);
            blueFire.SetActive(true);
            purpleFire.SetActive(false);
        }
        else if (playerVelocity > 130)
        {
            redFire.SetActive(false);
            orangeFire.SetActive(false);
            blueFire.SetActive(false);
            purpleFire.SetActive(true);
        }
        else if (playerVelocity > 110)
        {
            redFire.SetActive(true);
            orangeFire.SetActive(false);
            blueFire.SetActive(false);
            purpleFire.SetActive(false);

        }
        else if (playerVelocity > 100)
        {

            redFire.SetActive(false);
            orangeFire.SetActive(true);
            blueFire.SetActive(false);
            purpleFire.SetActive(false);
        }
    }

    void CheckPlayerPosition()
    {

        // Player is moving on x axis when not suppose to , this method corrects player if player is out of position
        if (playerPosition == 0 && (this.transform.position.x > -6.95 || this.transform.position.x < -7.05))
        {
            player.transform.position = new Vector3(-7f, this.transform.position.y, player.transform.position.z);
        } 
        else if (playerPosition == 1 && (this.transform.position.x > -3.45 || this.transform.position.x < -3.55))
        {
            player.transform.position = new Vector3(-3.5f, this.transform.position.y, player.transform.position.z);
        } 
        else if (playerPosition == 2 && (this.transform.position.x > 0.05 || this.transform.position.x < -0.05)) 
        {
            player.transform.position = new Vector3(0, this.transform.position.y, player.transform.position.z);
        }
        else if (playerPosition == 3 && (this.transform.position.x > 3.55 || this.transform.position.x < 3.45))
        {
            player.transform.position = new Vector3(3.5f, this.transform.position.y, player.transform.position.z);
        }
        else if (playerPosition == 4 && (this.transform.position.x > 7.05 || this.transform.position.x < 6.95))
        {
            player.transform.position = new Vector3(7f, this.transform.position.y, player.transform.position.z);
        }
    }

   void MoveRight()
    {
        if (playerPosition < 4 && !pauseMenuUI.activeInHierarchy && !loseMenuUI.activeInHierarchy)
        {
            player.transform.position += new Vector3(GameManager.Instance.SideMovement, 0f, 0f);
            playerPosition++;
        }
    }


    void MoveLeft()
    {
        if (playerPosition > 0 && !pauseMenuUI.activeInHierarchy && !loseMenuUI.activeInHierarchy)
        {
            player.transform.position -= new Vector3(GameManager.Instance.SideMovement, 0f, 0f);
            playerPosition--;
        }
    }

    void MoveUp()
    {
        if ((this.transform.position.y < 1.1)
         && !pauseMenuUI.activeInHierarchy && !loseMenuUI.activeInHierarchy)
        {
            rb.AddForce(0, jumpPower, 0, ForceMode.Impulse);
        }
    }
}
