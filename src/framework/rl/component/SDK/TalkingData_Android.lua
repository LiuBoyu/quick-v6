
local log = rl.log("SDK.TalkingData")

----------------------------------------
-- 组件·SDK.TalkingData(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.TalkingData(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local TalkingDataSDK = "org/cocos2dx/sdk/TalkingDataSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:onEventByTalkingDataSDK(e)
        log.debug("onEvent: %s", e)

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onEvent", { json.encode({

                        }) }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onLevelByTalkingDataSDK(e)
        log.debug("onLevel: %s", e)

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onLevel", { json.encode({
                                     cmd = e.cmd,
                                   level = e.level,
                                   cause = e.cause,
                        }) }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onUserByTalkingDataSDK(e)
        log.debug("onUser: %s", e)

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onUser", { json.encode({
                                     cmd = e.cmd,
                                playerID = e.playerID,
                                provider = e.provider,
                                   level = e.level,
                        }) }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onPayByTalkingDataSDK(e)
        log.debug("onPay: %s", e)

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onPay", { json.encode({
                                     cmd = e.cmd,
                                    cash = e.cash,
                                    coin = e.coin,
                                    item = e.item,
                                  amount = e.amount,
                                   price = e.price,
                                  source = e.source,
                                 orderId = e.orderId,
                                   iapId = e.iapId,
                        }) }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onBuyByTalkingDataSDK(e)
        log.debug("onBuy: %s", e)

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onBuy", { json.encode({
                                    item = e.item,
                                  amount = e.amount,
                                   price = e.price,
                        }) }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onUseByTalkingDataSDK(e)
        log.debug("onUse: %s", e)

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onUse", { json.encode({
                                    item = e.item,
                                  amount = e.amount,
                        }) }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onBonusByTalkingDataSDK(e)
        log.debug("onBonus: %s", e)

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onBonus", { json.encode({
                                     cmd = e.cmd,
                                    coin = e.coin,
                                  reason = e.reason,
                        }) }, "(Ljava/lang/String;)V")
        return ret
    end

    return component
end

