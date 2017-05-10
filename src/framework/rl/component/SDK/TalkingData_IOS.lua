
local log = rl.log("SDK.TalkingData")

----------------------------------------
-- 组件·SDK.TalkingData(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.TalkingData(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:onEventByTalkingDataSDK(e)
        log.debug("onEvent: %s", e)
    end

    function object:onLevelByTalkingDataSDK(e)
        log.debug("onLevel: %s", e)

        local ok, ret = luaoc.callStaticMethod("SDKApp", "onLevelByTalkingDataSDK", {
                                     cmd = e.cmd,
                                   level = e.level,
                                   cause = e.cause,
                        })
        return ret
    end

    function object:onUserByTalkingDataSDK(e)
        log.debug("onUser: %s", e)

        local ok, ret = luaoc.callStaticMethod("SDKApp", "onUserByTalkingDataSDK", {
                                     cmd = e.cmd,
                                playerID = e.playerID,
                                provider = e.provider,
                                   level = e.level,
                        })
        return ret
    end

    function object:onPayByTalkingDataSDK(e)
        log.debug("onPay: %s", e)

        local ok, ret = luaoc.callStaticMethod("SDKApp", "onPayByTalkingDataSDK", {
                                     cmd = e.cmd,
                                    cash = e.cash,
                                    coin = e.coin,
                                    item = e.item,
                                  amount = e.amount,
                                   price = e.price,
                                  source = e.source,
                                 orderId = e.orderId,
                                   iapId = e.iapId,
                        })
        return ret
    end

    return component
end

