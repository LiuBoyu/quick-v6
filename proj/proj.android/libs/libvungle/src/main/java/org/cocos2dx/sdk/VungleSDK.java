package org.cocos2dx.sdk;

import com.alibaba.fastjson.JSONObject;
import com.vungle.publisher.EventListener;
import com.vungle.publisher.VunglePub;

public class VungleSDK {

    private static final VunglePub vunglePub = VunglePub.getInstance();

    private static int onAdPlayableChangedCallback = 0;
    private static int onAdEndCallback = 0;

    //
    // 初始化
    //
    private static final EventListener vungleListener = new EventListener() {

        @Override
        public void onVideoView(boolean isCompletedView, int watchedMillis, int videoDurationMillis) {
        }

        @Override
        public void onAdStart() {
        }

        @Override
        public void onAdEnd(boolean wasSuccessfulView, boolean wasCallToActionClicked) {
            if (onAdEndCallback != 0) {
                SDKUtils.callLuaFunctionOnceOnGL(onAdEndCallback, serializeOnAdEnd(wasSuccessfulView, wasCallToActionClicked).toJSONString());
                onAdEndCallback = 0;
            }
        }

        @Override
        public void onAdPlayableChanged(boolean isAdPlayable) {
            if (onAdPlayableChangedCallback != 0) {
                if (isAdPlayable) {
                    SDKUtils.callLuaFunctionOnGL(onAdPlayableChangedCallback, "TRUE");
                } else {
                    SDKUtils.callLuaFunctionOnGL(onAdPlayableChangedCallback, "FALSE");
                }
            }
        }

        @Override
        public void onAdUnavailable(String reason) {
            if (onAdEndCallback != 0) {
                SDKUtils.callLuaFunctionOnceOnGL(onAdEndCallback, serializeOnAdEnd(false, false).toJSONString());
                onAdEndCallback = 0;
            }
        }

    };

    //
    // 初始化
    //
    public static void start() {
        vunglePub.init(SDKUtils.getContext(), SDKConfig.get("VungleAppId"));
        vunglePub.setEventListeners(vungleListener);
    }

    public static void onResume() {
        vunglePub.onResume();
    }

    public static void onPause() {
        vunglePub.onPause();
    }

    public static void onDestroy() {
        vunglePub.clearEventListeners();
    }

    //
    // 播放广告
    //
    public static void playAd(final int callback) {
        if (onAdEndCallback != 0) {
            SDKUtils.callLuaFunctionOnceOnGL(callback, serializeOnAdEnd(false, false).toJSONString());
            return;
        }

        onAdEndCallback = callback;

        vunglePub.playAd();
    }

    //
    // 广告状态
    //
    public static boolean isAdPlayable() {
        return vunglePub.isAdPlayable();
    }

    public static void setOnAdPlayableChanged(final int callback) {
        if (onAdPlayableChangedCallback != 0) {
            SDKUtils.releaseLuaFunctionOnGL(onAdPlayableChangedCallback);
        }
        onAdPlayableChangedCallback = callback;
    }

    //
    // tools
    //
    private static JSONObject serializeOnAdEnd(boolean wasSuccessfulView, boolean wasCallToActionClicked) {
        JSONObject ret = new JSONObject();

        ret.put("wasSuccessfulView", wasSuccessfulView);
        ret.put("wasCallToActionClicked", wasCallToActionClicked);

        return ret;
    }

}
