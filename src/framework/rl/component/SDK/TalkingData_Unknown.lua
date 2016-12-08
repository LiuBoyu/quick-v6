
local log = rl.log("SDK.TalkingData")

----------------------------------------
-- 组件·SDK.TalkingData(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.TalkingData(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:onProfileSignInByTalkingDataSDK(accountId)
        log.debug("onProfileSignIn: %s", accountId)
    end

    function object:onProfileSignOffByTalkingDataSDK()
        log.debug("onProfileSignOff")
    end

    function object:onEventByTalkingDataSDK(e)
        log.debug("onEvent: %s", e)
    end

    return component
end

