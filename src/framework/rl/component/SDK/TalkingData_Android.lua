
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

    function object:onProfileSignInByTalkingDataSDK(accountId)
        log.debug("onProfileSignIn: %s", accountId)

        local accountId = accountId or "Unknown"

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onProfileSignIn", {
                            accountId
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onProfileSignOffByTalkingDataSDK()
        log.debug("onProfileSignOff")

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onProfileSignOff", {
                        }, "()V")
        return ret
    end

    function object:onEventByTalkingDataSDK(e)
        log.debug("onEvent: %s", e)

        local ok, ret = luaj.callStaticMethod(TalkingDataSDK, "onEvent", {
                            json.encode({ id = e.id, kv = e.kv, du = e.du })
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onBuyByTalkingDataSDK(e)
        log.debug("onBuy: %s", e)
    end

    function object:onUseByTalkingDataSDK(e)
        log.debug("onUse: %s", e)
    end

    function object:onBonusByTalkingDataSDK(e)
        log.debug("onBonus: %s", e)
    end

    return component
end

