
local log = rl.log("SDK.Umeng")

----------------------------------------
-- 组件·SDK.Umeng(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Umeng(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local UmengSDK = "org/cocos2dx/sdk/UmengSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:onProfileSignInByUmengSDK(accountId)
        log.debug("onProfileSignIn: %s", accountId)

        local accountId = accountId or "Unknown"

        local ok, ret = luaj.callStaticMethod(UmengSDK, "onProfileSignIn", {
                            accountId
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onProfileSignOffByUmengSDK()
        log.debug("onProfileSignOff")

        local ok, ret = luaj.callStaticMethod(UmengSDK, "onProfileSignOff", {
                        }, "()V")
        return ret
    end

    function object:onEventByUmengSDK(e)
        log.debug("onEvent: %s", e)

        local ok, ret = luaj.callStaticMethod(UmengSDK, "onEvent", {
                            json.encode({ id = e.id, kv = e.kv, du = e.du })
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    return component
end

