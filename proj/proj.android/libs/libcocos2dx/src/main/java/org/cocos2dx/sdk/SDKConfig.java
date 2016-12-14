package org.cocos2dx.sdk;

import java.util.HashMap;

public class SDKConfig {

    private static HashMap<String, String> config = new HashMap<>();

    public static String get(String key) {
        return config.get(key);
    }

    public static void set(String key, String val) {
        config.put(key, val);
    }

}
