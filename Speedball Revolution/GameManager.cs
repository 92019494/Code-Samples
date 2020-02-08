using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : Singleton<GameManager> {

    private GameObject gemSound;

    private bool isCounting = false;
    public bool IsCounting
    {
        get { return isCounting; }
        set { isCounting = value; }
    }

    private bool rewardVideoWatched = false;
    public bool RewardVideoWatched
    {
        get { return rewardVideoWatched; }
        set { rewardVideoWatched = value; }
    }

    private int playerDeathCount = 0;
    public int PlayerDeathCount
    {
        get { return playerDeathCount; }
        set { playerDeathCount = value; }
    }

    private int gameCurrency = 0;
    public int GameCurrency
    {
        get { return gameCurrency; }
        set { gameCurrency = value; }
    }

    private int speedMultiplier;
    public int SpeedMultiplier
    {
        get { return speedMultiplier; }
        set { speedMultiplier = value; }
    }

    private int highScore;
    public int HighScore
    {
        get { return highScore; }
        set { highScore = value; }
    }

    private int score;
    public int Score
    {
        get { return score; }
        set { score = value; }
    }

    private bool invulnerable = false;
    public bool Invulnerable
    {
        get { return invulnerable; }
        set { invulnerable = value; }
    }

    private float speed = 70f;
    public float Speed
    {
        get { return speed; }
        set { speed = value; }
    }

    private float startingSpeed = 1f;
    public float StartingSpeed
    {
        get { return startingSpeed; }
        set { startingSpeed = value; }
    }


    private float sideMovement = 3.5f;
    public float SideMovement
    {
        get { return sideMovement; }
        set { sideMovement = value; }
    }


    private int lives;
    public int Lives
    {
        get { return lives; }
        set { lives = value; }
    }

    private int startNumLives = 1;
    public int StartNumLives
    {
        get { return startNumLives; }
        set { startNumLives = value; }
    }

  

    // Use this for initialization
    void Start () {
        
        // loading gem sound for score increment
        gemSound = Resources.Load<GameObject>("gemSound");

        isCounting = false;
        // Apples default frame rate at this time is 15fps which is makes the game look broken
        Application.targetFrameRate = 60;

        if (PlayerPrefs.HasKey("GameCurrency"))
        {
            gameCurrency = PlayerPrefs.GetInt("GameCurrency");
        }
        else
        {
            gameCurrency = 0;
        }  

       
        if (PlayerPrefs.HasKey("HighScore")){
            highScore = PlayerPrefs.GetInt("HighScore");
        }
        else
        {
            highScore = 0;
        }
        lives = startNumLives;
        GetMaxLevel();
  
       
    }

    private void Update()
    {
         if(playerDeathCount >= 5)
        {
            AdController.Instance.ShowVideoOrInterstitialAd();
            playerDeathCount = 0;
        }
    }



    public int GetMaxLevel() {

        return SceneManager.sceneCountInBuildSettings;

    }



    public void IncreaseGemCount(int number)
    {
        StartCoroutine(AddGems(number));
    }

    public void DecreaseGemCount(int number)
    {

        StartCoroutine(DecreaseGems(number));
    }

    // Animates gems being added
    IEnumerator AddGems(int number)
    {
        // setting is counting so user cant exit current screen
        GameManager.Instance.isCounting = true;

        // higher this number the quicker the increment
        int speedNum = 10;
        for (int i = 0; i < number % speedNum; i++)
        {
            gameCurrency++;
        }

        for (int i = 0; i < number; i+= speedNum)
        {
            gameCurrency += speedNum;
            if (i % 7 == 0) {
                Instantiate(gemSound, transform.position, transform.rotation);
            }

        yield return new WaitForSeconds(0.001f);

        }
        PlayerPrefs.SetInt("GameCurrency", gameCurrency);
        PlayerPrefs.Save();
        GameManager.Instance.isCounting = false;
    }

    // Animates gems being decreased
    IEnumerator DecreaseGems(int number)
    {
        // setting is counting so user cant exit current screen
        GameManager.Instance.isCounting = true;

        // higher this number the quicker the increment
        int speedNum = 10;
        for (int i = 0; i < number % speedNum; i++)
        {
            gameCurrency--;
        }

        for (int i = 0; i < number; i += speedNum)
        {
            gameCurrency -= speedNum;
            if (i % 7 == 0)
            {
                Instantiate(gemSound, transform.position, transform.rotation);
            }

            yield return new WaitForSeconds(0.001f);

        }
        PlayerPrefs.SetInt("GameCurrency", gameCurrency);
        PlayerPrefs.Save();
        GameManager.Instance.isCounting = false;
    }

}
