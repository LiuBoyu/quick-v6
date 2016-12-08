
local log = rl.log("SDK.Umeng")

----------------------------------------
-- 组件·SDK.Umeng(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Umeng(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:onProfileSignInByUmengSDK(accountId)
        log.debug("onProfileSignIn: %s", accountId)
    end

    function object:onProfileSignOffByUmengSDK()
        log.debug("onProfileSignOff")
    end

    function object:onEventByUmengSDK(e)
        log.debug("onEvent: %s", e)
    end

    return component
end

