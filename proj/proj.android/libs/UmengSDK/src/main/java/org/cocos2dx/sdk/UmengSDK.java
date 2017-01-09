package org.cocos2dx.sdk;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.umeng.analytics.MobclickAgent.EScenarioType;
import com.umeng.analytics.MobclickAgent.UMAnalyticsConfig;
import com.umeng.analytics.game.UMGameAgent;

import java.util.HashMap;

public class UmengSDK {

    //
    // 初始化
    //
    public static void start() {
        if (SDKUtils.isDebug()) {
            SDKConfig.set("UmengChannel", "DEBUG");
            UMGameAgent.setDebugMode(true);
        }
        UMAnalyticsConfig config = new UMAnalyticsConfig(SDKUtils.getContext(), SDKConfig.get("UmengAppKey"), SDKConfig.get("UmengChannel"), EScenarioType.E_UM_GAME);
        UMGameAgent.startWithConfigure(config);
        UMGameAgent.init(SDKUtils.getContext());
    }

    public static void onResume() {
        UMGameAgent.onResume(SDKUtils.getContext());
    }

    public static void onPause() {
        UMGameAgent.onPause(SDKUtils.getContext());
    }

    public static void onDestroy() {
        UMGameAgent.onKillProcess(SDKUtils.getContext());
    }

    //
    // 统计
    //
    public static void onProfileSignIn(String accountId) {
        UMGameAgent.onProfileSignIn(accountId);
    }

    public static void onProfileSignOff() {
        UMGameAgent.onProfileSignOff();
    }

    public static void onEvent(String json) {
        JSONObject args = JSON.parseObject(json);

        HashMap<String, String> kv = new HashMap<>();

        if (args.containsKey("kv")) {
            JSONObject obj = args.getJSONObject("kv");

            for (String k : obj.keySet()) {
                kv.put(k, obj.getString(k));
            }
        }

        String id = args.getString("id");

        if (args.containsKey("du")) {
            UMGameAgent.onEventValue(SDKUtils.getContext(), id, kv, args.getInteger("du"));
        } else {
            if (kv.size() > 0) {
                UMGameAgent.onEvent(SDKUtils.getContext(), id, kv);
            } else {
                UMGameAgent.onEvent(SDKUtils.getContext(), id);
            }
        }
    }

}
