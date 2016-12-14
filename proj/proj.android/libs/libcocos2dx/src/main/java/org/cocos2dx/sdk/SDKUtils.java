package org.cocos2dx.sdk;

import java.lang.reflect.Method;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.util.Log;

import com.alibaba.fastjson.JSONObject;

public class SDKUtils {

    //
    // context - 上下文环境
    //
    public static void setContext(Context context) {
        s_context = context;
    }

    public static Context getContext() {
        return s_context;
    }

    private static Context s_context;

    public static void setDebug(boolean debug) {
        s_debug = debug;
    }

    public static boolean isDebug() {
        return s_debug;
    }

    private static boolean s_debug = false;

    //
    // context - 上下文环境
    //
    public static Context getApplicationContext() {
        return s_context.getApplicationContext();
    }

    public static Application getApplication() {
        return ((Activity) s_context).getApplication();
    }

    public static Activity getMainActivity() {
        return (Activity) s_context;
    }

    //
    // thread - 线程函数
    //
    public static void runOnUI(final Runnable runnable) {
        ((Cocos2dxActivity) getContext()).runOnUiThread(runnable);
    }

    public static void runOnGL(final Runnable runnable) {
        ((Cocos2dxActivity) getContext()).runOnGLThread(runnable);
    }

    //
    // call lua - 调用Lua函数
    //
    public static void callLuaFunctionOnGL(final int luaFunctionId) {
        callLuaFunctionOnGL(luaFunctionId, null);
    }

    public static void callLuaFunctionOnGL(final int luaFunctionId, final String value) {
        runOnGL(new Runnable() {
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaFunctionId, value);
            }
        });
    }

    public static void callLuaFunctionOnceOnGL(final int luaFunctionId) {
        callLuaFunctionOnceOnGL(luaFunctionId, null);
    }

    public static void callLuaFunctionOnceOnGL(final int luaFunctionId, final String value) {
        runOnGL(new Runnable() {
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaFunctionId, value);
                Cocos2dxLuaJavaBridge.releaseLuaFunction(luaFunctionId);
            }
        });
    }

    public static void retainLuaFunctionOnGL(final int luaFunctionId) {
        runOnGL(new Runnable() {
            public void run() {
                Cocos2dxLuaJavaBridge.retainLuaFunction(luaFunctionId);
            }
        });
    }

    public static void releaseLuaFunctionOnGL(final int luaFunctionId) {
        runOnGL(new Runnable() {
            public void run() {
                Cocos2dxLuaJavaBridge.releaseLuaFunction(luaFunctionId);
            }
        });
    }

    //
    // call java - 调用java函数
    //
    public static Object invoke(final Class<?> clazz, final String methodName, final Class<?>[] classes, final Object[] objects) {
        try {
            Method method = clazz.getDeclaredMethod(methodName, classes);
            method.setAccessible(true);
            return method.invoke(null, objects);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //
    // get param - 获取参数
    //
    public static boolean getParamB(final JSONObject obj, final String k, final boolean v) {
        if (obj != null && obj.containsKey(k)) {
            return obj.getBooleanValue(k);
        }
        return v;
    }

    public static int getParamI(final JSONObject obj, final String k, final int v) {
        if (obj != null && obj.containsKey(k)) {
            return obj.getIntValue(k);
        }
        return v;
    }

    public static String getParamS(final JSONObject obj, final String k, final String v) {
        if (obj != null && obj.containsKey(k)) {
            return obj.getString(k);
        }
        return v;
    }

    //
    // debug - 调试日志
    //
    public static void log(String format, Object... args) {
        Log.d("DEBUG", String.format(format, args));
    }

}
