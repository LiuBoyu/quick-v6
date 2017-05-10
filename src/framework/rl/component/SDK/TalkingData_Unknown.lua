
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

    function object:onEventByTalkingDataSDK(e)
        log.debug("onEvent: %s", e)
    end

    function object:onLevelByTalkingDataSDK(e)
        log.debug("onLevel: %s", e)
    end

    function object:onUserByTalkingDataSDK(e)
        log.debug("onUser: %s", e)
    end

    function object:onPayByTalkingDataSDK(e)
        log.debug("onPay: %s", e)
    end

    return component
end

