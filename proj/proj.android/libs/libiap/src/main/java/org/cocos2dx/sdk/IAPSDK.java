package org.cocos2dx.sdk;

import android.content.Intent;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.android.vending.util.IabHelper;
import com.android.vending.util.IabResult;
import com.android.vending.util.Inventory;
import com.android.vending.util.Purchase;
import com.android.vending.util.SkuDetails;

import java.util.ArrayList;
import java.util.List;

public class IAPSDK {

    private static final int s_RC_REQUEST = 10001;

    private static IabHelper s_iab;
    private static Inventory s_inventory;

    private static int onPurchaseFinishedCallback = 0;

    //
    // 初始化商店·回调
    //
    public static void setOnPurchaseFinished(final int callback) {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                if (onPurchaseFinishedCallback != 0) {
                    SDKUtils.releaseLuaFunctionOnGL(onPurchaseFinishedCallback);
                }
                onPurchaseFinishedCallback = callback;
            }
        });
    }

    //
    // 卸载商店
    //
    public static void unload() {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                if (s_iab != null) {
                    s_iab.dispose();
                    s_iab = null;
                }
                if (s_inventory != null) {
                    s_inventory = null;
                }
                if (onPurchaseFinishedCallback != 0) {
                    SDKUtils.releaseLuaFunctionOnGL(onPurchaseFinishedCallback);
                    onPurchaseFinishedCallback = 0;
                }
            }
        });
    }

    //
    // 初始化商店
    //
    public static void startSetup(final int callback) {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                s_iab = new IabHelper(SDKUtils.getContext(), SDKConfig.get("GooglePlayPublicKey"));

                if (SDKUtils.isDebug()) {
                    s_iab.enableDebugLogging(true);
                }

                s_iab.startSetup(new IabHelper.OnIabSetupFinishedListener() {
                    public void onIabSetupFinished(final IabResult result) {
                        if (s_iab == null) {
                            SDKUtils.releaseLuaFunctionOnGL(callback);
                            return;
                        }

                        JSONObject ret = new JSONObject();

                        if (result.isFailure()) {
                            ret.put("e", serializeIabError(result));
                        }

                        SDKUtils.callLuaFunctionOnceOnGL(callback, ret.toJSONString());
                    }
                });
            }
        });
    }

    public static void onDestroy() {
        if (s_iab != null) {
            s_iab.dispose();
            s_iab = null;
        }
    }

    //
    // 加载商店
    //
    public static void queryInventory(final ArrayList<String> consumableProductIds, final ArrayList<String> nonConsumableProductIds, final int callback) {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                // 合并产品ID
                List<String> productIds = new ArrayList<String>();

                productIds.addAll(consumableProductIds);
                productIds.addAll(nonConsumableProductIds);

                // 查询商店
                s_iab.queryInventoryAsync(true, productIds, new IabHelper.QueryInventoryFinishedListener() {
                    public void onQueryInventoryFinished(final IabResult result, final Inventory inventory) {
                        if (s_iab == null) {
                            SDKUtils.releaseLuaFunctionOnGL(callback);
                            return;
                        }

                        JSONObject ret = new JSONObject();

                        if (result.isFailure()) {
                            ret.put("e", serializeIabError(result));

                        } else {
                            // 初始化
                            s_inventory = inventory;

                            JSONArray consumableProducts = new JSONArray();
                            JSONArray nonConsumableProducts = new JSONArray();
                            JSONArray invalidIds = new JSONArray();

                            // 可消耗品
                            for (String productId : consumableProductIds) {
                                SkuDetails product = s_inventory.getSkuDetails(productId);

                                if (product != null) {
                                    consumableProducts.add(serializeIabProduct(product));
                                } else {
                                    invalidIds.add(productId);
                                }
                            }

                            // 非消耗品
                            for (String productId : nonConsumableProductIds) {
                                SkuDetails product = s_inventory.getSkuDetails(productId);

                                if (product != null) {
                                    nonConsumableProducts.add(serializeIabProduct(product));
                                } else {
                                    invalidIds.add(productId);
                                }
                            }

                            // 已购买可消耗品
                            List<Purchase> consumablePurchases = new ArrayList<Purchase>();

                            for (String productId : consumableProductIds) {
                                Purchase purchase = s_inventory.getPurchase(productId);

                                if (purchase != null) {
                                    s_inventory.erasePurchase(purchase.getSku());

                                    consumablePurchases.add(purchase);

                                    SDKUtils.log("ConsumablePurchases: %s", purchase);
                                }
                            }

                            // 处理未完成的交易
                            if (consumablePurchases.size() > 0) {
                                s_iab.consumeAsync(consumablePurchases, new IabHelper.OnConsumeMultiFinishedListener() {
                                    public void onConsumeMultiFinished(final List<Purchase> purchases, final List<IabResult> results) {
                                        if (s_iab == null)
                                            return;

                                        for (int i = 0; i < purchases.size(); i++) {
                                            JSONObject ret = new JSONObject();

                                            if (results.get(i).isFailure()) {
                                                // 消费失败
                                                ret.put("ts", serializeIabTransaction("Failed", purchases.get(i), results.get(i)));
                                            } else {
                                                // 消费成功
                                                ret.put("ts", serializeIabTransaction("Purchased", purchases.get(i), results.get(i)));
                                            }

                                            if (onPurchaseFinishedCallback != 0) {
                                                SDKUtils.callLuaFunctionOnGL(onPurchaseFinishedCallback, ret.toJSONString());
                                            }
                                        }
                                    }
                                });
                            }

                            // 已购买非消耗品
                            // nothing

                            // 返回值
                            ret.put("consumableProducts", consumableProducts);
                            ret.put("nonConsumableProducts", nonConsumableProducts);
                            ret.put("invalidIds", invalidIds);
                        }

                        SDKUtils.callLuaFunctionOnceOnGL(callback, ret.toJSONString());
                    }
                });
            }
        });
    }

    //
    // 查询商品
    //
    public static String getProduct(String productId) {
        SkuDetails product = s_inventory.getSkuDetails(productId);

        if (product != null) {
            return serializeIabProduct(product).toJSONString();
        } else {
            return null;
        }
    }

    public static boolean isPurchased(String productId) {
        Purchase purchase = s_inventory.getPurchase(productId);

        if (purchase != null) {
            return true;
        } else {
            return false;
        }
    }

    //
    // 购买商品·可消耗品
    //
    public static void purchaseConsumable(final String productId) {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                s_iab.launchPurchaseFlow(SDKUtils.getMainActivity(), productId, IabHelper.ITEM_TYPE_INAPP, s_RC_REQUEST,
                        new IabHelper.OnIabPurchaseFinishedListener() {
                            public void onIabPurchaseFinished(final IabResult result, final Purchase purchase) {
                                if (s_iab == null)
                                    return;

                                JSONObject ret = new JSONObject();

                                if (result.isFailure()) {
                                    if (result.getResponse() == IabHelper.IABHELPER_USER_CANCELLED) {
                                        // 交易取消
                                        ret.put("ts", serializeIabTransaction("Cancelled", purchase, result));
                                    } else {
                                        // 交易失败
                                        ret.put("ts", serializeIabTransaction("Failed", purchase, result));
                                    }

                                    if (onPurchaseFinishedCallback != 0) {
                                        SDKUtils.callLuaFunctionOnGL(onPurchaseFinishedCallback, ret.toJSONString());
                                    }
                                } else {
                                    // 交易完成
                                    s_iab.consumeAsync(purchase, new IabHelper.OnConsumeFinishedListener() {
                                        public void onConsumeFinished(final Purchase purchase, final IabResult result) {
                                            if (s_iab == null)
                                                return;

                                            JSONObject ret = new JSONObject();

                                            if (result.isFailure()) {
                                                // 消费失败
                                                ret.put("ts", serializeIabTransaction("Failed", purchase, result));
                                            } else {
                                                // 消费成功
                                                ret.put("ts", serializeIabTransaction("Purchased", purchase, result));
                                            }

                                            if (onPurchaseFinishedCallback != 0) {
                                                SDKUtils.callLuaFunctionOnGL(onPurchaseFinishedCallback, ret.toJSONString());
                                            }
                                        }
                                    });
                                }
                            }
                        }, "");
            }
        });
    }

    //
    // 购买商品·非消耗品
    //
    public static void purchaseNonConsumable(final String productId) {
        SDKUtils.runOnUI(new Runnable() {
            public void run() {
                s_iab.launchPurchaseFlow(SDKUtils.getMainActivity(), productId, IabHelper.ITEM_TYPE_INAPP, s_RC_REQUEST,
                        new IabHelper.OnIabPurchaseFinishedListener() {
                            public void onIabPurchaseFinished(final IabResult result, final Purchase purchase) {
                                if (s_iab == null)
                                    return;

                                JSONObject ret = new JSONObject();

                                if (result.isFailure()) {
                                    if (result.getResponse() == IabHelper.IABHELPER_USER_CANCELLED) {
                                        // 交易取消
                                        ret.put("ts", serializeIabTransaction("Cancelled", purchase, result));
                                    } else {
                                        // 交易失败
                                        ret.put("ts", serializeIabTransaction("Failed", purchase, result));
                                    }
                                } else {
                                    // 交易完成
                                    ret.put("ts", serializeIabTransaction("Purchased", purchase, result));
                                }

                                if (onPurchaseFinishedCallback != 0) {
                                    SDKUtils.callLuaFunctionOnGL(onPurchaseFinishedCallback, ret.toJSONString());
                                }
                            }
                        }, "");
            }
        });
    }

    //
    // 系统函数
    //
    public static boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (s_iab != null) {
            return s_iab.handleActivityResult(requestCode, resultCode, data);
        } else {
            return false;
        }
    }

    //
    // 辅助函数
    //
    private static JSONObject serializeIabError(IabResult result) {
        JSONObject ret = new JSONObject();

        ret.put("code", result.getResponse());
        ret.put("text", result.getMessage());

        return ret;
    }

    private static JSONObject serializeIabProduct(SkuDetails skuDetails) {
        JSONObject ret = new JSONObject();

        ret.put("id", skuDetails.getSku());
        ret.put("price", skuDetails.getPrice() + " " + skuDetails.getCurrency());
        ret.put("title", skuDetails.getTitle());
        ret.put("description", skuDetails.getDescription());

        return ret;
    }

    private static JSONObject serializeIabTransaction(String state, Purchase purchase, IabResult result) {
        JSONObject ret = new JSONObject();

        if (state.equals("Purchased")) {
            ret.put("state", state);
            ret.put("id", purchase.getToken());
            ret.put("date", purchase.getPurchaseTime());
            ret.put("productId", purchase.getSku());
            ret.put("receipt", purchase.getOriginalJson());
        }

        if (state.equals("Cancelled") || state.equals("Failed")) {
            ret.put("state", state);
            ret.put("error", serializeIabError(result));
        }

        return ret;
    }

}
