using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Monetization;

public class AdController : Singleton<AdController> {

    private string androidStoreID = "3033050"; 
    private string appleStoreID = "3033051";

    private string videoAd = "video";
    private string rewardedVideoAd = "rewardedVideo";
    private string bannerAd = "bannerAd";
    

    // Use this for initialization
    void Start () {

        if (Application.platform == RuntimePlatform.Android) {
            Monetization.Initialize(androidStoreID, false);
        } 
        else if (Application.platform == RuntimePlatform.IPhonePlayer) { 
        Monetization.Initialize(appleStoreID, false);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Time.timeSinceLevelLoad < 2)
        {
            //ShowBannerAd();
        }


    }

    public void ShowVideoOrInterstitialAd()
    {
        // is video ad ready to be played
        if (Monetization.IsReady(videoAd))
        {

            ShowAdPlacementContent ad = null;
            ad = Monetization.GetPlacementContent(videoAd) as ShowAdPlacementContent;

            if (ad != null)
            {
                ad.Show();
            }
        }
    }

    public void ShowRewardedVideoAd()
    {
        // is rewarded video ad ready to be played
        if (Monetization.IsReady(rewardedVideoAd))
        {

            ShowAdPlacementContent ad = null;
            ad = Monetization.GetPlacementContent(rewardedVideoAd) as ShowAdPlacementContent;

            if (ad != null)
            {
                ad.Show();
            }
        }
    }

    public void ShowBannerAd()
    {
        // is rewarded banner ad ready to be played
        if (Monetization.IsReady(bannerAd))
        {

            ShowAdPlacementContent ad = null;
            ad = Monetization.GetPlacementContent(bannerAd) as ShowAdPlacementContent;
          
            if (ad != null)
            {
                ad.Show();
            }
        }
    }
}
