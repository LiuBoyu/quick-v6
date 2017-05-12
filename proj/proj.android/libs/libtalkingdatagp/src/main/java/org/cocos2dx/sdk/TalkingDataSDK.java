package org.cocos2dx.sdk;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.tendcloud.tenddata.TDGAAccount;
import com.tendcloud.tenddata.TDGAItem;
import com.tendcloud.tenddata.TDGAMission;
import com.tendcloud.tenddata.TDGAVirtualCurrency;
import com.tendcloud.tenddata.TalkingDataGA;

import java.util.HashMap;

public class TalkingDataSDK {

    private static TDGAAccount player = null;

    //
    // 初始化
    //
    public static void start() {
        TalkingDataGA.init(SDKUtils.getMainActivity(), SDKConfig.get("TalkingDataAppId"), SDKConfig.get("TalkingDataChannel"));
    }

    public static void onResume() {
        TalkingDataGA.onResume(SDKUtils.getMainActivity());
    }

    public static void onPause() {
        TalkingDataGA.onPause(SDKUtils.getMainActivity());
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
        } else {
            if (kv.size() > 0) {
            } else {
            }
        }
    }

    public static void onLevel(String json) {
        JSONObject args = JSON.parseObject(json);

        String cmd = args.getString("cmd");
        String level = args.getString("level");
        String cause = args.getString("cause");

        if (cmd.equals("start")) {
            TDGAMission.onBegin(level);
        }
        if (cmd.equals("finish")) {
            TDGAMission.onCompleted(level);
        }
        if (cmd.equals("fail")) {
            TDGAMission.onFailed(level, cause);
        }
    }

    public static void onUser(String json) {
        JSONObject args = JSON.parseObject(json);

        String cmd = args.getString("cmd");

        if (cmd.equals("login")) {
            String playerID = args.getString("playerID");
            String provider = args.getString("provider");

            player = TDGAAccount.setAccount(playerID);

            if (provider.equals("registered")) {
                player.setAccountType(TDGAAccount.AccountType.REGISTERED);
            } else if (provider.equals("facebook")) {
                player.setAccountType(TDGAAccount.AccountType.TYPE1);
            } else {
                player.setAccountType(TDGAAccount.AccountType.ANONYMOUS);
            }
        }
        if (cmd.equals("logout")) {
        }
        if (cmd.equals("level")) {
            int level = args.getIntValue("level");

            if (player != null) {
                player.setLevel(level);
            }
        }
    }

    public static void onPay(String json) {
        JSONObject args = JSON.parseObject(json);

        String cmd = args.getString("cmd");

        if (cmd.equals("coin")) {
            String orderId = args.getString("orderId");
            String iapId = args.getString("iapId");
            double cash = args.getDoubleValue("cash");
            double coin = args.getDoubleValue("coin");
            String source = args.getString("source");

            TDGAVirtualCurrency.onChargeRequest(orderId, iapId, cash, "USD", coin, source);
            TDGAVirtualCurrency.onChargeSuccess(orderId);
        }
    }

    public static void onBuy(String json) {
        JSONObject args = JSON.parseObject(json);

        String item = args.getString("item");
        int amount = args.getIntValue("amount");
        double price = args.getDoubleValue("price");

        TDGAItem.onPurchase(item, amount, price);
    }

    public static void onUse(String json) {
        JSONObject args = JSON.parseObject(json);

        String item = args.getString("item");
        int amount = args.getIntValue("amount");

        TDGAItem.onUse(item, amount);
    }

    public static void onBonus(String json) {
        JSONObject args = JSON.parseObject(json);

        String cmd = args.getString("cmd");

        if (cmd.equals("coin")) {
            double coin = args.getDoubleValue("coin");
            String reason = args.getString("reason");

            TDGAVirtualCurrency.onReward(coin, reason);
        }
    }

}
