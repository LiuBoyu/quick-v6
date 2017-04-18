
local log = rl.log("SDK.Facebook")

----------------------------------------
-- 组件·FacebookSDK(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Facebook(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:logInByFacebookSDK(callback)
        log.debug("logIn")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "logInByFacebookSDK", {
                            callback = callback
                        })
        return ret
    end

    function object:logOutByFacebookSDK()
        log.debug("logOut")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "logOutByFacebookSDK")
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

        local ok, ret = luaoc.callStaticMethod("SDKApp", "setOnCurrentAccessTokenChangedByFacebookSDK", {
                            callback = callback,
                        })
        return ret
    end

    function object:getCurrentAccessTokenByFacebookSDK()
        log.debug("getCurrentAccessToken")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "getCurrentAccessTokenByFacebookSDK")
        if ret then
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

        local callback   = function(e, res) if e then end
            if args.callback then
                args.callback(res)
            end
        end

        local ok, ret = luaoc.callStaticMethod("SDKApp", "requestByFacebookSDK", {
                            recipients = json.encode(recipients),
                               message = message,
                                 title = title,
                              callback = callback,
                        })
        return ret
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:GETbyFacebookSDK(args)
        log.debug("GET: %s", args)

        local graphPath  = string.sub(args.graphPath,2)
        local parameters = json.encode(args.parameters)

        local callback   = function(e, res) if e then end
            if args.callback then
                args.callback(res)
            end
        end

        local ok, ret = luaoc.callStaticMethod("SDKApp", "GETByFacebookSDK", {
                            graphPath = graphPath,
                           parameters = parameters,
                             callback = callback,
                        })
        return ret
    end

    return component
end

