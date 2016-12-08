
local log = rl.log("SDK.Testin")

----------------------------------------
-- 组件·TestinSDK(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Testin(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local TestinSDK = "com/havefunstudios/sdk/TestinSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:setUserInfoByTestinSDK(userInfo)
        log.debug("setUserInfo: %s", userInfo)

        local ok, ret = luaj.callStaticMethod(TestinSDK, "setUserInfo", {
                            userInfo
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:reportExceptionByTestinSDK(message, stackTrace)
        log.debug("reportException: %s\n%s", message, stackTrace)

        local ok, ret = luaj.callStaticMethod(TestinSDK, "reportException", {
                            message, stackTrace
                        }, "(Ljava/lang/String;Ljava/lang/String;)V")
        return ret
    end

    function object:leaveBreadcrumbByTestinSDK(string)
        log.debug("leaveBreadcrumb: %s", string)

        local ok, ret = luaj.callStaticMethod(TestinSDK, "leaveBreadcrumb", {
                            string
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    return component
end

