
local log = rl.log("SDK.Dataeye")

----------------------------------------
-- 组件·SDK.Dataeye(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Dataeye(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:loginByDataeyeSDK(accountId)
        log.debug("login: %s", accountId)
    end

    function object:logoutByDataeyeSDK()
        log.debug("logout")
    end

    return component
end

