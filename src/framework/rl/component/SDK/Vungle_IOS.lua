
local log = rl.log("SDK.Vungle")

----------------------------------------
-- 组件·VungleSDK(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Vungle(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:playAdByVungleSDK(callback)
        log.debug("playAd")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "playAdByVungleSDK",{
                            callback = callback,
                        })
        return ret
    end

    function object:isAdPlayableByVungleSDK()
        log.debug("isAdPlayable")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "isAdPlayableByVungleSDK")
        return ret
    end

    function object:setOnAdPlayableChangedByVungleSDK(callback)
        log.debug("setOnAdPlayableChanged")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "setOnAdPlayableChangedByVungleSDK", {
                            callback = callback,
                        })
        return ret
    end

    return component
end

