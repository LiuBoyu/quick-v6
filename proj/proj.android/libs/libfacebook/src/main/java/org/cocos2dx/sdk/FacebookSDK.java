package org.cocos2dx.sdk;

import android.content.Intent;
import android.os.Bundle;

import com.alibaba.fastjson.JSONObject;
import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.widget.GameRequestDialog;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

public class FacebookSDK {

    private static CallbackManager callbackManager;

    private static AccessTokenTracker accessTokenTracker;
    private static GameRequestDialog requestDialog;

    private static int onCurrentAccessTokenChangedCallback = 0;
    private static int onRequestCallback = 0;
    private static int onLoginCallback = 0;

    //
    // 初始化
    //
    public static void start() {
        // FacebookSdk.sdkInitialize(SDKUtils.getApplicationContext());
        AppEventsLogger.activateApp(SDKUtils.getApplication());

        callbackManager = CallbackManager.Factory.create();

        LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {
            public void onSuccess(LoginResult loginResult) {
                if (onLoginCallback != 0) {
                    SDKUtils.callLuaFunctionOnceOnGL(onLoginCallback, "Success");
                    onLoginCallback = 0;
                }
            }

            public void onCancel() {
                if (onLoginCallback != 0) {
                    SDKUtils.callLuaFunctionOnceOnGL(onLoginCallback, "Cancel");
                    onLoginCallback = 0;
                }
            }

            public void onError(FacebookException error) {
                if (onLoginCallback != 0) {
                    SDKUtils.callLuaFunctionOnceOnGL(onLoginCallback, "Error");
                    onLoginCallback = 0;
                }
            }
        });

        accessTokenTracker = new AccessTokenTracker() {
            protected void onCurrentAccessTokenChanged(AccessToken oldAccessToken, AccessToken currentAccessToken) {
                if (onCurrentAccessTokenChangedCallback != 0) {
                    JSONObject ret = new JSONObject();

                    if (oldAccessToken != null)
                        ret.put("oldAccessToken", serializeAccessToken(oldAccessToken));

                    if (currentAccessToken != null)
                        ret.put("currentAccessToken", serializeAccessToken(currentAccessToken));

                    SDKUtils.callLuaFunctionOnGL(onCurrentAccessTokenChangedCallback, ret.toJSONString());
                }
            }
        };

        requestDialog = new GameRequestDialog(SDKUtils.getMainActivity());
        requestDialog.registerCallback(callbackManager, new FacebookCallback<GameRequestDialog.Result>() {
            public void onSuccess(GameRequestDialog.Result result) {
                if (onRequestCallback != 0) {
                    SDKUtils.callLuaFunctionOnceOnGL(onRequestCallback, "Success");
                    onRequestCallback = 0;
                }
            }

            public void onCancel() {
                if (onRequestCallback != 0) {
                    SDKUtils.callLuaFunctionOnceOnGL(onRequestCallback, "Cancel");
                    onRequestCallback = 0;
                }
            }

            public void onError(FacebookException error) {
                if (onRequestCallback != 0) {
                    SDKUtils.callLuaFunctionOnceOnGL(onRequestCallback, "Error");
                    onRequestCallback = 0;
                }
            }
        });
    }

    public static void onResume() {
    }

    public static void onPause() {
    }

    public static void onDestroy() {
        accessTokenTracker.stopTracking();
    }

    //
    // 初始化
    //
    public static void onActivityResult(int requestCode, int resultCode, Intent data) {
        callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    //
    // 登录&注销
    //
    public static void logIn(final int callback) {
        if (onLoginCallback != 0) {
            SDKUtils.callLuaFunctionOnceOnGL(callback, "Cancel");
            return;
        }

        onLoginCallback = callback;

        LoginManager.getInstance().logInWithReadPermissions(SDKUtils.getMainActivity(), Arrays.asList("public_profile", "user_friends"));
        // Arrays.asList("public_profile", "user_friends") "publish_actions"
    }

    public static void logOut() {
        LoginManager.getInstance().logOut();
    }

    //
    // AccessToken
    //
    public static void setOnCurrentAccessTokenChanged(final int callback) {
        if (onCurrentAccessTokenChangedCallback != 0) {
            SDKUtils.releaseLuaFunctionOnGL(onCurrentAccessTokenChangedCallback);
        }
        onCurrentAccessTokenChangedCallback = callback;
    }

    public static String getCurrentAccessToken() {
        AccessToken token = AccessToken.getCurrentAccessToken();

        if (token != null)
            return serializeAccessToken(token).toJSONString();

        return "null";
    }

    private static JSONObject serializeAccessToken(AccessToken token) {
        JSONObject ret = new JSONObject();

        ret.put("token", token.getToken());
        ret.put("applicationId", token.getApplicationId());
        ret.put("userId", token.getUserId());
        ret.put("permissions", token.getPermissions());
        ret.put("declinedPermissions", token.getDeclinedPermissions());
        ret.put("isExpired", token.isExpired());

        return ret;
    }

    //
    // 邀请&礼物
    //
    public static void request(final ArrayList<String> recipients, final String message, final String title, final int callback) {
        if (onRequestCallback != 0) {
            SDKUtils.callLuaFunctionOnceOnGL(callback, "Cancel");
            return;
        }

        onRequestCallback = callback;

        GameRequestContent content = new GameRequestContent.Builder()
                .setRecipients(recipients)
                .setMessage(message)
                .setTitle(title)
                .build();
        requestDialog.show(content);
    }

    //
    // GraphAPI
    //
    public static void GET(final String graphPath, final HashMap<String, String> parameters, final int callback) {
        GraphRequest request = new GraphRequest(
                AccessToken.getCurrentAccessToken(),
                graphPath,
                toParameters(parameters),
                HttpMethod.GET,
                new GraphRequest.Callback() {
                    public void onCompleted(GraphResponse response) {
                        if (response.getError() == null) {
                            SDKUtils.callLuaFunctionOnceOnGL(callback, response.getJSONObject().toString());
                        } else {
                            SDKUtils.callLuaFunctionOnceOnGL(callback, response.getError().toString());
                        }
                    }
                });
        request.executeAsync();
    }

    private static Bundle toParameters(final HashMap<String, String> parameters) {
        Bundle bundle = new Bundle();

        for (String key : parameters.keySet()) {
            bundle.putString(key, parameters.get(key));
        }

        return bundle;
    }
    //分享

}
