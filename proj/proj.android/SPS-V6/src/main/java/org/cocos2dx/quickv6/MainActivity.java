package org.cocos2dx.quickv6;

import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.sdk.SDKConfig;
import org.cocos2dx.sdk.SDKUtils;

public class MainActivity extends Cocos2dxActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 锁定屏幕
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        // 初始化
        SDKUtils.setDebug(org.cocos2dx.quickv6.BuildConfig.DEBUG);
        SDKUtils.setContext(this);

        // Config
        SDKConfig.set("GooglePlayPublicKey", "?");
        SDKConfig.set("UmengAppKey", "?");
        SDKConfig.set("UmengChannel", "GP");
        SDKConfig.set("VungleAppId", "Test_Android");

        // SDK
        startSDK("org.cocos2dx.sdk.IAPSDK");
        startSDK("org.cocos2dx.sdk.UmengSDK");
        startSDK("org.cocos2dx.sdk.VungleSDK");
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

}
