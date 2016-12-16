package org.cocos2dx.sdk;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.exceptions.SFSException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

import sfs2x.client.SmartFox;
import sfs2x.client.core.BaseEvent;
import sfs2x.client.core.IEventListener;
import sfs2x.client.core.SFSEvent;
import sfs2x.client.requests.ExtensionRequest;
import sfs2x.client.requests.IRequest;
import sfs2x.client.requests.LoginRequest;
import sfs2x.client.requests.LogoutRequest;
import sfs2x.client.util.ConfigData;

public class SFClientSDK {

    private static SmartFox sfsClient = new SmartFox();
    private static JSONObject sfsProtocol = new JSONObject();
    private static int sfsCallback = 0;

    //
    // 初始化
    //
    private static final IEventListener sfsListener = new IEventListener() {

        @Override
        public void dispatch(BaseEvent e) throws SFSException {
            recv(e.getType(), e.getArguments());
        }

    };

    //
    // 初始化
    //
    public static void start(final String json, final int callback) {
        JSONObject args = JSON.parseObject(json);

        if (args.containsKey("protocol")) {
            sfsProtocol = args.getJSONObject("protocol");
        }

        if (args.containsKey("debug")) {
            sfsClient.setDebug(true);
        }

        sfsCallback = callback;

        sfsClient.addEventListener(SFSEvent.CONNECTION, sfsListener);
        sfsClient.addEventListener(SFSEvent.CONNECTION_LOST, sfsListener);
        sfsClient.addEventListener(SFSEvent.CONNECTION_RETRY, sfsListener);
        sfsClient.addEventListener(SFSEvent.CONNECTION_ATTEMPT_HTTP, sfsListener);
        sfsClient.addEventListener(SFSEvent.CONNECTION_RESUME, sfsListener);
        sfsClient.addEventListener(SFSEvent.UDP_INIT, sfsListener);

        sfsClient.addEventListener(SFSEvent.LOGIN, sfsListener);
        sfsClient.addEventListener(SFSEvent.LOGIN_ERROR, sfsListener);
        sfsClient.addEventListener(SFSEvent.LOGOUT, sfsListener);

        sfsClient.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsListener);

        sfsClient.addEventListener(SFSEvent.PUBLIC_MESSAGE, sfsListener);
        sfsClient.addEventListener(SFSEvent.PRIVATE_MESSAGE, sfsListener);
        sfsClient.addEventListener(SFSEvent.MODERATOR_MESSAGE, sfsListener);
        sfsClient.addEventListener(SFSEvent.ADMIN_MESSAGE, sfsListener);
        sfsClient.addEventListener(SFSEvent.OBJECT_MESSAGE, sfsListener);

        sfsClient.addEventListener(SFSEvent.PING_PONG, sfsListener);
    }

    public static void connect(final String json) {
        JSONObject args = JSON.parseObject(json);

        ConfigData config = new ConfigData();

        if (args.containsKey("host")) config.setHost(args.getString("host"));
        if (args.containsKey("port")) config.setPort(args.getIntValue("port"));

        if (args.containsKey("udpHost")) config.setUdpHost(args.getString("udpHost"));
        if (args.containsKey("udpPort")) config.setUdpPort(args.getIntValue("udpPort"));

        if (args.containsKey("zone")) config.setZone(args.getString("zone"));
        if (args.containsKey("debug")) config.setDebug(args.getBooleanValue("debug"));

        config.setUseBBox(false);

        sfsClient.connect(config);
    }

    public static void disconnect() {
        sfsClient.disconnect();
    }

    public static void killConnection() {
        sfsClient.killConnection();
    }

    public static void enableLagMonitor(final String json) {
        JSONObject args = JSON.parseObject(json);

        boolean enabled = SDKUtils.getParamB(args, "enabled", true);
        int interval = SDKUtils.getParamI(args, "interval", 5);
        int queueSize = SDKUtils.getParamI(args, "queueSize", 10);

        sfsClient.enableLagMonitor(enabled, interval, queueSize);
    }

    public static void send(final String json) {
        JSONObject args = JSON.parseObject(json);

        IRequest request = null;

        String cmd = args.getString("cmd");
        JSONObject payload = args.getJSONObject("payload");

        if (cmd != null) {
            JSONObject protocol = getProtocolBySEND(cmd);

            switch (cmd) {
                case "@login": {

                    SFSObject obj = null;

                    JSONObject v = protocol.getJSONObject("params");
                    JSONObject o = payload.getJSONObject("params");

                    if (v != null && o != null) {
                        obj = toSFSObject(o, v);
                    }

                    request = new LoginRequest(payload.getString("userName"), payload.getString("password"), payload.getString("zoneName"), obj);

                    break;
                }
                case "@logout":

                    request = new LogoutRequest();

                    break;
                default: {

                    SFSObject obj = null;

                    if (payload != null) {
                        obj = toSFSObject(payload, protocol);
                    }

                    request = new ExtensionRequest(cmd, obj);

                    break;
                }
            }
        }

        if (request != null) {
            sfsClient.send(request);
        }
    }

    public static void recv(String cmd, Map<String, Object> payload) {
        ISFSObject params = null;

        if (cmd.equals("extensionResponse")) {
            params = (ISFSObject) payload.get("params");
            cmd = (String) payload.get("cmd");
        } else {
            cmd = "@" + cmd;
        }

        if (cmd.equals("@loginError")) {
            cmd = "@login";
        }

        JSONObject protocol = getProtocolByRECV(cmd);
        JSONObject ret = new JSONObject();

        ret.put("cmd", cmd);

        if (cmd.startsWith("@")) {
            if (payload != null) {
                if (protocol.size() > 0) {
                    ret.put("payload", otSFSMap(payload, protocol));
                } else {
                    ret.put("payload", JSON.toJSON(payload));
                }
            }
        } else {
            if (params != null) {
                ret.put("payload", otSFSObject(params, protocol));
            }
        }

        SDKUtils.callLuaFunctionOnGL(sfsCallback, ret.toJSONString());
    }

    //
    // 辅助函数
    //

    private static JSONObject getProtocolBySEND(String cmd) {
        JSONObject protocol = sfsProtocol.getJSONObject(cmd);

        if (protocol == null) {
            return new JSONObject();
        }
        if (protocol.containsKey("request")) {
            return protocol.getJSONObject("request");
        }
        if (protocol.containsKey("message")) {
            return protocol.getJSONObject("message");
        }

        return protocol;
    }

    private static JSONObject getProtocolByRECV(String cmd) {
        JSONObject protocol = sfsProtocol.getJSONObject(cmd);

        if (protocol == null) {
            return new JSONObject();
        }
        if (protocol.containsKey("response")) {
            return protocol.getJSONObject("response");
        }
        if (protocol.containsKey("message")) {
            return protocol.getJSONObject("message");
        }

        return protocol;
    }

    //
    // 辅助函数
    //

    private static SFSObject toSFSObject(JSONObject payload, JSONObject protocol) {
        SFSObject obj = new SFSObject();

        for (String k : protocol.keySet()) {
            Object v = protocol.get(k);

            if (payload.get(k) == null || v == null) {
                continue;
            }

            if (v instanceof Integer) {
                switch ((Integer) v) {
                    case 10: // boolean
                        obj.putBool(k, payload.getBooleanValue(k));
                        break;
                    case 11: // int
                        obj.putInt(k, payload.getIntValue(k));
                        break;
                    case 12: // float
                        obj.putFloat(k, payload.getFloatValue(k));
                        break;
                    case 13: // string
                        obj.putUtfString(k, payload.getString(k));
                        break;
                    case 15: // long
                        obj.putLong(k, payload.getLongValue(k));
                        break;
                    case 16: // double
                        obj.putDouble(k, payload.getDoubleValue(k));
                        break;
                    case 20: // boolean[]
                        obj.putBoolArray(k, toCollection(payload.getJSONArray(k), Boolean.class));
                        break;
                    case 21: // int[]
                        obj.putIntArray(k, toCollection(payload.getJSONArray(k), Integer.class));
                        break;
                    case 22: // float[]
                        obj.putFloatArray(k, toCollection(payload.getJSONArray(k), Float.class));
                        break;
                    case 23: // string[]
                        obj.putUtfStringArray(k, toCollection(payload.getJSONArray(k), String.class));
                        break;
                    case 25: // long[]
                        obj.putLongArray(k, toCollection(payload.getJSONArray(k), Long.class));
                        break;
                    case 26: // double[]
                        obj.putDoubleArray(k, toCollection(payload.getJSONArray(k), Double.class));
                        break;
                }
            } else if (v instanceof JSONObject) {

                obj.putSFSObject(k, toSFSObject(payload.getJSONObject(k), (JSONObject) v));

            } else if (v instanceof JSONArray) {

                obj.putSFSArray(k, toSFSArray(payload.getJSONArray(k), (JSONArray) v));

            }
        }

        return obj;
    }

    private static SFSArray toSFSArray(JSONArray payload, JSONArray protocol) {
        SFSArray obj = new SFSArray();

        for (int i = 0; i < payload.size(); i++) {
            Object v = protocol.get(0);

            if (payload.get(i) == null || v == null) {
                continue;
            }

            if (v instanceof Integer) {
                switch ((Integer) v) {
                    case 10: // boolean
                        obj.addBool(payload.getBooleanValue(i));
                        break;
                    case 11: // int
                        obj.addInt(payload.getIntValue(i));
                        break;
                    case 12: // float
                        obj.addFloat(payload.getFloatValue(i));
                        break;
                    case 13: // string
                        obj.addUtfString(payload.getString(i));
                        break;
                    case 15: // long
                        obj.addLong(payload.getLongValue(i));
                        break;
                    case 16: // double
                        obj.addDouble(payload.getDoubleValue(i));
                        break;
                    case 20: // boolean[]
                        obj.addBoolArray(toCollection(payload.getJSONArray(i), Boolean.class));
                        break;
                    case 21: // int[]
                        obj.addIntArray(toCollection(payload.getJSONArray(i), Integer.class));
                        break;
                    case 22: // float[]
                        obj.addFloatArray(toCollection(payload.getJSONArray(i), Float.class));
                        break;
                    case 23: // string[]
                        obj.addUtfStringArray(toCollection(payload.getJSONArray(i), String.class));
                        break;
                    case 25: // long[]
                        obj.addLongArray(toCollection(payload.getJSONArray(i), Long.class));
                        break;
                    case 26: // double[]
                        obj.addDoubleArray(toCollection(payload.getJSONArray(i), Double.class));
                        break;
                }
            } else if (v instanceof JSONObject) {

                obj.addSFSObject(toSFSObject(payload.getJSONObject(i), (JSONObject) v));

            } else if (v instanceof JSONArray) {

                obj.addSFSArray(toSFSArray(payload.getJSONArray(i), (JSONArray) v));

            }
        }

        return obj;
    }

    private static <E> Collection<E> toCollection(JSONArray obj, Class<E> t) {
        ArrayList<E> ret = new ArrayList<>();

        for (int i = 0; i < obj.size(); i++) {
            ret.add(obj.getObject(i, t));
        }

        return ret;
    }

    //
    // 辅助函数
    //

    private static JSONObject otSFSMap(Map<String, Object> payload, JSONObject protocol) {
        JSONObject ret = new JSONObject();

        for (String k : protocol.keySet()) {
            Object v = protocol.get(k);

            if (payload.get(k) == null || v == null) {
                continue;
            }

            if (v instanceof Integer) {
                switch ((Integer) v) {
                    case 10: // boolean
                        ret.put(k, payload.get(k));
                        break;
                    case 11: // int
                        ret.put(k, payload.get(k));
                        break;
                    case 12: // float
                        ret.put(k, payload.get(k));
                        break;
                    case 13: // string
                        ret.put(k, payload.get(k));
                        break;
                    case 15: // long
                        ret.put(k, payload.get(k));
                        break;
                    case 16: // double
                        ret.put(k, payload.get(k));
                        break;
                    case 20: // boolean[]
                        ret.put(k, payload.get(k));
                        break;
                    case 21: // int[]
                        ret.put(k, payload.get(k));
                        break;
                    case 22: // float[]
                        ret.put(k, payload.get(k));
                        break;
                    case 23: // string[]
                        ret.put(k, payload.get(k));
                        break;
                    case 25: // long[]
                        ret.put(k, payload.get(k));
                        break;
                    case 26: // double[]
                        ret.put(k, payload.get(k));
                        break;
                }
            } else if (v instanceof JSONObject) {

                ret.put(k, otSFSObject((ISFSObject) payload.get(k), (JSONObject) v));

            } else if (v instanceof JSONArray) {

                ret.put(k, otSFSArray((ISFSArray) payload.get(k), (JSONArray) v));

            }
        }

        return ret;
    }

    private static JSONObject otSFSObject(ISFSObject payload, JSONObject protocol) {
        JSONObject ret = new JSONObject();

        for (String k : protocol.keySet()) {
            Object v = protocol.get(k);

            if (payload.get(k) == null || v == null) {
                continue;
            }

            if (v instanceof Integer) {
                switch ((Integer) v) {
                    case 10: // boolean
                        ret.put(k, payload.getBool(k));
                        break;
                    case 11: // int
                        ret.put(k, payload.getInt(k));
                        break;
                    case 12: // float
                        ret.put(k, payload.getFloat(k));
                        break;
                    case 13: // string
                        ret.put(k, payload.getUtfString(k));
                        break;
                    case 15: // long
                        ret.put(k, payload.getLong(k));
                        break;
                    case 16: // double
                        ret.put(k, payload.getDouble(k));
                        break;
                    case 20: // boolean[]
                        ret.put(k, payload.getBoolArray(k));
                        break;
                    case 21: // int[]
                        ret.put(k, payload.getIntArray(k));
                        break;
                    case 22: // float[]
                        ret.put(k, payload.getFloatArray(k));
                        break;
                    case 23: // string[]
                        ret.put(k, payload.getUtfStringArray(k));
                        break;
                    case 25: // long[]
                        ret.put(k, payload.getLongArray(k));
                        break;
                    case 26: // double[]
                        ret.put(k, payload.getDoubleArray(k));
                        break;
                }
            } else if (v instanceof JSONObject) {

                ret.put(k, otSFSObject(payload.getSFSObject(k), (JSONObject) v));

            } else if (v instanceof JSONArray) {

                ret.put(k, otSFSArray(payload.getSFSArray(k), (JSONArray) v));

            }
        }

        return ret;
    }

    private static JSONArray otSFSArray(ISFSArray payload, JSONArray protocol) {
        JSONArray ret = new JSONArray();

        if (payload == null) {
            return ret;
        }

        for (int i = 0; i < payload.size(); i++) {
            Object v = protocol.get(0);

            if (payload.get(i) == null || v == null) {
                continue;
            }

            if (v instanceof Integer) {
                switch ((Integer) v) {
                    case 10: // boolean
                        ret.add(payload.getBool(i));
                        break;
                    case 11: // int
                        ret.add(payload.getInt(i));
                        break;
                    case 12: // float
                        ret.add(payload.getFloat(i));
                        break;
                    case 13: // string
                        ret.add(payload.getUtfString(i));
                        break;
                    case 15: // long
                        ret.add(payload.getLong(i));
                        break;
                    case 16: // double
                        ret.add(payload.getDouble(i));
                        break;
                    case 20: // boolean[]
                        ret.add(payload.getBoolArray(i));
                        break;
                    case 21: // int[]
                        ret.add(payload.getIntArray(i));
                        break;
                    case 22: // float[]
                        ret.add(payload.getFloatArray(i));
                        break;
                    case 23: // string[]
                        ret.add(payload.getUtfStringArray(i));
                        break;
                    case 25: // long[]
                        ret.add(payload.getLongArray(i));
                        break;
                    case 26: // double[]
                        ret.add(payload.getDoubleArray(i));
                        break;
                }
            } else if (v instanceof JSONObject) {

                ret.add(otSFSObject(payload.getSFSObject(i), (JSONObject) v));

            } else if (v instanceof JSONArray) {

                ret.add(otSFSArray(payload.getSFSArray(i), (JSONArray) v));

            }
        }

        return ret;
    }

}
