package org.cocos2dx.sdk;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.tendcloud.tenddata.TCAgent;

import java.util.HashMap;

public class TalkingDataSDK {

    //
    // 初始化
    //
    public static void start() {
        if (SDKUtils.isDebug()) {
            SDKConfig.set("TalkingDataChannel", "DEBUG");
            TCAgent.LOG_ON = true;
        }
        TCAgent.init(SDKUtils.getApplication(), SDKConfig.get("TalkingDataAppKey"), SDKConfig.get("TalkingDataChannel"));
    }

    public static void onResume() {
        TCAgent.onResume(SDKUtils.getMainActivity());
    }

    public static void onPause() {
        TCAgent.onPause(SDKUtils.getMainActivity());
    }

    public static void onDestroy() {
    }

    // 统计
    //
    public static void onProfileSignIn(String accountId) {
    }

    public static void onProfileSignOff() {
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

        TCAgent.onEvent(SDKUtils.getContext(), id, "", kv);
    }

}
