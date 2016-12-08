
local log = rl.log("SDK.Testin")

----------------------------------------
-- 组件·TestinSDK(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Testin(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:setUserInfoByTestinSDK(userInfo)
        log.debug("setUserInfo: %s", userInfo)

        local ok, ret = luaoc.callStaticMethod("SDKApp", "setUserInfoByTestinSDK", {
                            userInfo    = userInfo,
                        })
        return ret
    end

    function object:reportExceptionByTestinSDK(message, stackTrace)
        log.debug("reportException: %s\n%s", message, stackTrace)

        local ok, ret = luaoc.callStaticMethod("SDKApp", "reportExceptionByTestinSDK", {
                            message     = message,
                            stackTrace  = stackTrace,
                        })
        return ret
    end

    function object:leaveBreadcrumbByTestinSDK(string)
        log.debug("leaveBreadcrumb: %s", string)

        local ok, ret = luaoc.callStaticMethod("SDKApp", "leaveBreadcrumbByTestinSDK", {
                            string      = string,
                        })
        return ret
    end

    return component
end

