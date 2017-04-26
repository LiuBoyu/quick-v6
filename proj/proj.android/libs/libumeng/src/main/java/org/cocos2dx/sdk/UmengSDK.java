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

    public static void onLevel(String json) {
        JSONObject args = JSON.parseObject(json);

        String cmd = args.getString("cmd");
        String level = args.getString("level");

        if (cmd.equals("start")) {
            UMGameAgent.startLevel(level);
        }
        if (cmd.equals("finish")) {
            UMGameAgent.finishLevel(level);
        }
        if (cmd.equals("fail")) {
            UMGameAgent.failLevel(level);
        }
    }

    public static void onUser(String json) {
        JSONObject args = JSON.parseObject(json);

        String cmd = args.getString("cmd");

        if (cmd.equals("login")) {
            String playerID = args.getString("playerID");
            String provider = args.getString("provider");

            if (provider != null) {
                UMGameAgent.onProfileSignIn(playerID);
            } else {
                UMGameAgent.onProfileSignIn(playerID, provider);
            }
        }
        if (cmd.equals("logout")) {
            UMGameAgent.onProfileSignOff();
        }
        if (cmd.equals("level")) {
            int level = args.getIntValue("level");

            UMGameAgent.setPlayerLevel(level);
        }
    }

    public static void onPay(String json) {
        JSONObject args = JSON.parseObject(json);

        String cmd = args.getString("cmd");

        if (cmd.equals("coin")) {
            double cash = args.getDoubleValue("cash");
            double coin = args.getDoubleValue("coin");
            int source = args.getIntValue("source");

            UMGameAgent.pay(cash, coin, source);
        }
        if (cmd.equals("item")) {
            double cash = args.getDoubleValue("cash");
            String item = args.getString("item");
            int amount = args.getIntValue("amount");
            double price = args.getDoubleValue("price");
            int source = args.getIntValue("source");

            UMGameAgent.pay(cash, item, amount, price, source);
        }
    }

    public static void onBuy(String json) {
        // todo
    }

    public static void onUse(String json) {
        // todo
    }

    public static void onBonus(String json) {
        // todo
    }

}
