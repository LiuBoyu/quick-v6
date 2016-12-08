
local log = rl.log("SDK.Dataeye")

----------------------------------------
-- 组件·SDK.Dataeye(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Dataeye(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local DataeyeSDK = "com/havefunstudios/sdk/DataeyeSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:loginByDataeyeSDK(accountId)
        log.debug("login: %s", accountId)

        local accountId = accountId or "Unknown"

        local ok, ret = luaj.callStaticMethod(DataeyeSDK, "login", {
                            accountId
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:logoutByDataeyeSDK()
        log.debug("logout")

        local ok, ret = luaj.callStaticMethod(DataeyeSDK, "logout", {
                        }, "()V")
        return ret
    end

    return component
end

