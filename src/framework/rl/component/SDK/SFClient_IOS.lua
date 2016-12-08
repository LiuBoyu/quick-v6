
local log = rl.log("SDK.SFClient")

----------------------------------------
-- 组件·SDK.SFClient(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.SFClient(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:startBySFClientSDK(args)
        local ok, ret = luaoc.callStaticMethod("SFClientSDK", "start", {
                           protocol = json.encode(args.protocol),
                              debug = args.debug,
                                log = args.log,
                           callback = args.callback,
                        })
        return ret
    end

    function object:connectBySFClientSDK(args)
        local ok, ret = luaoc.callStaticMethod("SFClientSDK", "connect", {
                               host = args.host,
                               port = args.port,
                            udpHost = args.udpHost,
                            udpPort = args.udpPort,
                               zone = args.zone,
                              debug = args.debug,
                        })
        return ret
    end

    function object:disconnectBySFClientSDK()
        local ok, ret = luaoc.callStaticMethod("SFClientSDK", "disconnect")
        return ret
    end

    function object:killConnectionBySFClientSDK()
        local ok, ret = luaoc.callStaticMethod("SFClientSDK", "killConnection")
        return ret
    end

    function object:enableLagMonitorBySFClientSDK(args)
        local ok, ret = luaoc.callStaticMethod("SFClientSDK", "enableLagMonitor", {
                            enabled = args.enabled,
                           interval = args.interval,
                          queueSize = args.queueSize,
                        })
        return ret
    end

    function object:sendBySFClientSDK(cmd, payload)
        local ok, ret = luaoc.callStaticMethod("SFClientSDK", "send", {
                                cmd = cmd,
                            payload = json.encode(payload or {}),
                        })
        return ret
    end

    return component
end

