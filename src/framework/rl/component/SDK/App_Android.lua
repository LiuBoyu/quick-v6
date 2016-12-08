
local log = rl.log("SDK.App")

----------------------------------------
-- 组件·SDK.App(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.App(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local SDKApp = "org/cocos2dx/sdk/SDKApp"

----------------------------------------
-- 组件参数
----------------------------------------

    local function getAppInfo()
        local ok, ret = luaj.callStaticMethod(SDKApp, "getAppInfo", {
                        }, "()Ljava/lang/String;")
        return json.decode(ret)
    end

    local function getDevInfo()
        local ok, ret = luaj.callStaticMethod(SDKApp, "getDevInfo", {
                        }, "()Ljava/lang/String;")
        return json.decode(ret)
    end

    local function getUdid()
        local ok, ret = luaj.callStaticMethod(SDKApp, "getUdid", {
                        }, "()Ljava/lang/String;")
        return ret
    end

    local function getUuid()
        local ok, ret = luaj.callStaticMethod(SDKApp, "getUuid", {
                        }, "()Ljava/lang/String;")
        return ret
    end

----------------------------------------
-- 组件参数
----------------------------------------

    local appInfo = getAppInfo()
    local devInfo = getDevInfo()
    local udid    = getUdid()

    log.info("getInfo: %s", { appInfo = appInfo, devInfo = devInfo, udid = udid })

----------------------------------------
-- 对象方法
----------------------------------------

    function object:getAppInfo()
        return appInfo
    end

    function object:getDevInfo()
        return devInfo
    end

    function object:getUdid()
        return udid
    end

    function object:getUuid()
        return getUuid()
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:mailto(args)
        log.debug("mailto: %s", args)

        local recipient = args.recipient
        local subject   = args.subject
        local body      = args.body

        local ok, ret = luaj.callStaticMethod(SDKApp, "mailto", {
                            recipient, subject, body
                        }, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
        return ret
    end

    function object:openUrl(url)
        log.debug("openUrl: %s", url)

        local ok, ret = luaj.callStaticMethod(SDKApp, "openUrl", {
                            url
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    local vibrateEnabled

    function object:vibrate(t)
        log.debug("vibrate: %s", t)

        if not vibrateEnabled then
            return
        end

        local ok, ret = luaj.callStaticMethod(SDKApp, "vibrate", {
                            t or 1000
                        }, "(I)V")
        return ret
    end

    function object:setVibrateEnabled(enabled)
        vibrateEnabled = enabled
    end

    return component
end

