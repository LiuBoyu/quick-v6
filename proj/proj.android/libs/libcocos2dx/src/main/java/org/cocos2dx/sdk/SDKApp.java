package org.cocos2dx.sdk;

import java.util.Locale;
import java.util.UUID;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.Uri;
import android.os.Build;
import android.os.Vibrator;
import android.provider.Settings.Secure;

import com.alibaba.fastjson.JSONObject;

public class SDKApp {

    static Vibrator vibrator = null;

    //
    // DevInfo
    //
    public static String getDevInfo() {
        JSONObject ret = new JSONObject();

        ret.put("model", Build.MODEL);
        ret.put("os", getOS());

        return ret.toJSONString();
    }

    public static JSONObject getOS() {
        JSONObject ret = new JSONObject();

        ret.put("name", "Android");
        ret.put("version", Build.VERSION.RELEASE);

        ret.put("country", Locale.getDefault().getCountry());
        ret.put("language", Locale.getDefault().getLanguage());

        return ret;
    }

    //
    // AppInfo
    //
    public static String getAppInfo() {
        JSONObject ret = new JSONObject();

        String pkgName = SDKUtils.getContext().getPackageName();
        ret.put("id", pkgName);

        PackageManager pm = SDKUtils.getContext().getPackageManager();

        try {
            ApplicationInfo appInfo = pm.getApplicationInfo(pkgName, 0);
            ret.put("name", pm.getApplicationLabel(appInfo));
        } catch (NameNotFoundException e) {
        }

        try {
            PackageInfo pkgInfo = pm.getPackageInfo(pkgName, 0);
            ret.put("version", pkgInfo.versionName);
            ret.put("build", pkgInfo.versionCode);
        } catch (NameNotFoundException e) {
        }

        return ret.toJSONString();
    }

    //
    // UDID && UUID
    //
    public static String getUdid() {
        return Secure.getString(SDKUtils.getContext().getContentResolver(), Secure.ANDROID_ID);
    }

    public static String getUuid() {
        return UUID.randomUUID().toString();
    }

    //
    // Mail
    //
    public static void mailto(final String recipient, final String subject, final String body) {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                Intent data = new Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:" + recipient));

                // 设置标题
                data.putExtra(Intent.EXTRA_SUBJECT, subject);
                // 设置文本
                data.putExtra(Intent.EXTRA_TEXT, body);

                SDKUtils.getContext().startActivity(Intent.createChooser(data, ""));
            }
        });
    }

    //
    // OpenUrl
    //
    public static void openUrl(final String url) {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                Intent data = new Intent(Intent.ACTION_VIEW, Uri.parse(url));

                SDKUtils.getContext().startActivity(data);
            }
        });
    }

    //
    // Vibrate
    //
    public static void vibrate(final int time) {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                if (vibrator == null) {
                    vibrator = (Vibrator) SDKUtils.getContext().getSystemService(Context.VIBRATOR_SERVICE);
                }
                vibrator.vibrate(time);
            }
        });
    }

}
