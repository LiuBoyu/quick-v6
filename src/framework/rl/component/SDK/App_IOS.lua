
local log = rl.log("SDK.App")

----------------------------------------
-- 组件·SDK.App(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.App(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 组件参数
----------------------------------------

    local function getDeviceInfo()
        log.debug("getDeviceInfo")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "getDeviceInfo")
        return ret
    end

    local function getAppInfo()
        log.debug("getAppInfo")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "getAppInfo")
        return ret
    end

    local function getUdid()
        log.debug("getUdid")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "getUdid")
        return ret
    end

    local function getUuid()
        log.debug("getUuid")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "getUuid")
        return ret
    end

----------------------------------------
-- 组件参数
----------------------------------------

    local deviceInfo = getDeviceInfo()
    local appInfo    = getAppInfo()
    local udid       = getUdid()

    log.info("getInfo: %s", { deviceInfo = deviceInfo, appInfo = appInfo, udid = udid })

----------------------------------------
-- 对象方法
----------------------------------------

    function object:getDeviceInfo()
        return deviceInfo
    end

    function object:getAppInfo()
        return appInfo
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

        local ok, ret = luaoc.callStaticMethod("SDKApp", "mailto", {
                            recipient = recipient,
                            subject   = subject,
                            body      = body,
                        })
        return ret
    end

    function object:openUrl(url)
        log.debug("openUrl: %s", url)

        local ok, ret = luaoc.callStaticMethod("SDKApp", "openUrl", {
                            url = url,
                        })
        return ret
    end

    local vibrateEnabled

    function object:vibrate(t)
        log.debug("vibrate: %s", t)

        if vibrateEnabled == 1 then
            return
        end

        local ok, ret = luaoc.callStaticMethod("SDKApp", "vibrate", {
                            time = t or 1000,
                        })
        return ret
    end

    function object:setVibrateEnabled(enabled)
        vibrateEnabled = enabled
    end

    return component
end

