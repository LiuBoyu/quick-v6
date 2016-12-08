
local log = rl.log("SDK.Vungle")

----------------------------------------
-- 组件·VungleSDK(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Vungle(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local VungleSDK = "com/havefunstudios/sdk/VungleSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:playAdByVungleSDK(callback)
        log.debug("playAd")

        local ok, ret = luaj.callStaticMethod(VungleSDK, "playAd", {
                            callback,
                        }, "(I)V")
        return ret
    end

    function object:isAdPlayableByVungleSDK()
        log.debug("isAdPlayable")

        local ok, ret = luaj.callStaticMethod(VungleSDK, "isAdPlayable", {
                        }, "()Z")
        return ret
    end

    function object:setOnAdPlayableChangedByVungleSDK(callback)
        log.debug("setOnAdPlayableChanged")

        local ok, ret = luaj.callStaticMethod(VungleSDK, "setOnAdPlayableChanged", {
                            callback,
                        }, "(I)V")
        return ret
    end

    return component
end

