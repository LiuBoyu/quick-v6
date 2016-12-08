
local log = rl.log("SDK.Testin")

----------------------------------------
-- 组件·TestinSDK(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Testin(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:setUserInfoByTestinSDK(userInfo)
        log.debug("setUserInfo: %s", userInfo)
    end

    function object:reportExceptionByTestinSDK(message, stackTrace)
        log.debug("reportException: %s\n%s", message, stackTrace)
    end

    function object:leaveBreadcrumbByTestinSDK(string)
        log.debug("leaveBreadcrumb: %s", string)
    end

    return component
end

