
local log = rl.log("SDK.App")

----------------------------------------
-- 组件·SDK.App(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.App(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 组件参数
----------------------------------------

    local appInfo = {
        id      = APP_ID,
        name    = APP_NAME,
        version = APP_VERSION,
        build   = APP_BUILD,
    }

    local devInfo = {
        model = "Player3",
        os    = {
            name     = "Mac",
            version  = "0.1",
            country  = "US", -- US, CN
            language = "en", -- en, zh
        },
    }

    local udid = "0"

    if os.exists(cc.FileUtils:getInstance():getWritablePath() .. "/.udid") then
        udid = os.read(cc.FileUtils:getInstance():getWritablePath() .. "/.udid")
    end

----------------------------------------
-- 组件参数
----------------------------------------

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
        return "0"
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:mailto(args)
        log.debug("mailto: %s", args)
    end

    function object:openUrl(url)
        log.debug("openUrl: %s", url)
    end

    function object:vibrate(t)
        log.debug("vibrate: %s", t)
    end

    function object:setVibrateEnabled(enabled)
    end

    return component
end

