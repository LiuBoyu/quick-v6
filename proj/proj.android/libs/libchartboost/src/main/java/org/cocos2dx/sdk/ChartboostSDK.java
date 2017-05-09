package org.cocos2dx.sdk;

import com.alibaba.fastjson.JSONObject;
import com.chartboost.sdk.Chartboost;
import com.chartboost.sdk.CBLocation;
import com.chartboost.sdk.ChartboostDelegate;

public class ChartboostSDK {

    //
    // 初始化
    //
    public static void start() {
        Chartboost.startWithAppId(SDKUtils.getMainActivity(), SDKConfig.get("ChartboostAppId"), SDKConfig.get("ChartboostAppSignature"));
        Chartboost.onCreate(SDKUtils.getMainActivity());
        Chartboost.setShouldRequestInterstitialsInFirstSession(false);
    }

    public static void onStart() {
        Chartboost.onStart(SDKUtils.getMainActivity());
    }

    public static void onResume() {
        Chartboost.onResume(SDKUtils.getMainActivity());
    }

    public static void onPause() {
        Chartboost.onPause(SDKUtils.getMainActivity());
    }

    public static void onStop() {
        Chartboost.onStop(SDKUtils.getMainActivity());
    }

    public static void onDestroy() {
        Chartboost.onDestroy(SDKUtils.getMainActivity());
    }

    //
    // 播放广告
    //
    public static void playAd(final int callback) {
    }

    //
    // 广告状态
    //
    public static boolean isAdPlayable() {
        return false;
    }

    //
    // 播放广告
    //
    public static void playIt() {
        Chartboost.showInterstitial(CBLocation.LOCATION_HOME_SCREEN);
    }

    //
    // 广告状态
    //
    public static boolean isItPlayable() {
        if (Chartboost.hasInterstitial(CBLocation.LOCATION_HOME_SCREEN)) {
            return true;
        } else {
            Chartboost.cacheInterstitial(CBLocation.LOCATION_HOME_SCREEN);
            return false;
        }
    }

}
