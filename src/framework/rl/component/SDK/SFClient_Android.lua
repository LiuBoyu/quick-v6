
local log = rl.log("SDK.SFClient")

----------------------------------------
-- 组件·SDK.SFClient(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.SFClient(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local SFClientSDK = "org/cocos2dx/sdk/SFClientSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:startBySFClientSDK(args)
        local ok, ret = luaj.callStaticMethod(SFClientSDK, "start", {
                            json.encode({
                                protocol = args.protocol,
                                   debug = args.debug,
                                     log = args.log,
                            }),
                            function(e) e = json.decode(e) or {}
                                if args.callback then
                                    args.callback(e.cmd, e.payload)
                                end
                            end,
                        }, "(Ljava/lang/String;I)V")
        return ret
    end

    function object:connectBySFClientSDK(args)
        local ok, ret = luaj.callStaticMethod(SFClientSDK, "connect", {
                            json.encode({
                                   host = args.host,
                                   port = args.port,
                                udpHost = args.udpHost,
                                udpPort = args.udpPort,
                                   zone = args.zone,
                                  debug = args.debug,
                            }),
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:disconnectBySFClientSDK()
        local ok, ret = luaj.callStaticMethod(SFClientSDK, "disconnect", {
                        }, "()V")
        return ret
    end

    function object:killConnectionBySFClientSDK()
        local ok, ret = luaj.callStaticMethod(SFClientSDK, "killConnection", {
                        }, "()V")
        return ret
    end

    function object:enableLagMonitorBySFClientSDK(args)
        local ok, ret = luaj.callStaticMethod(SFClientSDK, "enableLagMonitor", {
                            json.encode({
                                  enabled = args.enabled,
                                 interval = args.interval,
                                queueSize = args.queueSize,
                            }),
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:sendBySFClientSDK(cmd, payload)
        local ok, ret = luaj.callStaticMethod(SFClientSDK, "send", {
                            json.encode({
                                    cmd = cmd,
                                payload = payload,
                            }),
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    return component
end

