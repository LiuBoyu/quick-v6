
local log = rl.log("SDK.Facebook")

----------------------------------------
-- 组件·FacebookSDK(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Facebook(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local FacebookSDK = "org/cocos2dx/sdk/FacebookSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:logInByFacebookSDK(callback)
        log.debug("logIn")

        local ok, ret = luaj.callStaticMethod(FacebookSDK, "logIn", {
                            callback
                        }, "(I)V")
        return ret
    end

    function object:logOutByFacebookSDK()
        log.debug("logOut")

        local ok, ret = luaj.callStaticMethod(FacebookSDK, "logOut", {
                        }, "()V")
        return ret
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:setOnCurrentAccessTokenChangedByFacebookSDK(callback)
        log.debug("setOnCurrentAccessTokenChanged")

        local callback = function(args) args = json.decode(args)
            local old     = args.oldAccessToken
            local current = args.currentAccessToken
            return callback(old, current)
        end

        local ok, ret = luaj.callStaticMethod(FacebookSDK, "setOnCurrentAccessTokenChanged", {
                            callback
                        }, "(I)V")
        return ret
    end

    function object:getCurrentAccessTokenByFacebookSDK()
        log.debug("getCurrentAccessToken")

        local ok, ret = luaj.callStaticMethod(FacebookSDK, "getCurrentAccessToken", {
                        }, "()Ljava/lang/String;")
        if ret ~= "null" then
            return json.decode(ret)
        end
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:requestByFacebookSDK(args)
        log.debug("request: %s", args)

        local recipients = args.recipients or {}
        local message    = args.message
        local title      = args.title
        local callback   = args.callback

        local ok, ret = luaj.callStaticMethod(FacebookSDK, "request", {
                            recipients, message, title, callback
                        }, "(Ljava/util/ArrayList;Ljava/lang/String;Ljava/lang/String;I)V")
        return ret
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:GETbyFacebookSDK(args)
        log.debug("GET: %s", args)

        local graphPath  = args.graphPath
        local parameters = args.parameters or {}
        local callback   = function(res)
            return args.callback(json.decode(res))
        end

        local ok, ret = luaj.callStaticMethod(FacebookSDK, "GET", {
                            graphPath, parameters, callback
                        }, "(Ljava/lang/String;Ljava/util/HashMap;I)V")
        return ret
    end

    return component
end

