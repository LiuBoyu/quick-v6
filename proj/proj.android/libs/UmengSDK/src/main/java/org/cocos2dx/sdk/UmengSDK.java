package org.cocos2dx.sdk;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.umeng.analytics.MobclickAgent;
import com.umeng.analytics.MobclickAgent.EScenarioType;
import com.umeng.analytics.MobclickAgent.UMAnalyticsConfig;

import java.util.HashMap;

public class UmengSDK {

    //
    // 初始化
    //
    public static void start() {
        if (SDKUtils.isDebug()) {
            SDKConfig.set("UmengChannel", "DEBUG");
            MobclickAgent.setDebugMode(true);
        }
        UMAnalyticsConfig config = new UMAnalyticsConfig(SDKUtils.getContext(), SDKConfig.get("UmengAppKey"), SDKConfig.get("UmengChannel"), EScenarioType.E_UM_GAME);
        MobclickAgent.startWithConfigure(config);
    }

    public static void onResume() {
        MobclickAgent.onResume(SDKUtils.getContext());
    }

    public static void onPause() {
        MobclickAgent.onPause(SDKUtils.getContext());
    }

    public static void onDestroy() {
        MobclickAgent.onKillProcess(SDKUtils.getContext());
    }
    //

    // 统计
    //
    public static void onProfileSignIn(String accountId) {
        MobclickAgent.onProfileSignIn(accountId);
    }

    public static void onProfileSignOff() {
        MobclickAgent.onProfileSignOff();
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
            MobclickAgent.onEventValue(SDKUtils.getContext(), id, kv, args.getInteger("du"));
        } else {
            if (kv.size() > 0) {
                MobclickAgent.onEvent(SDKUtils.getContext(), id, kv);
            } else {
                MobclickAgent.onEvent(SDKUtils.getContext(), id);
            }
        }
    }

}
