
local log = rl.log("SDK.Vungle")

----------------------------------------
-- 组件·VungleSDK(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Vungle(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local isAdPlayable = true
    local onAdPlayableChanged

----------------------------------------
-- 对象方法
----------------------------------------

    function object:playAdByVungleSDK(callback)
        log.debug("playAd")

        isAdPlayable = false

        if onAdPlayableChanged then
            onAdPlayableChanged(false)
        end

        callback({ isCompletedView = true })

        isAdPlayable = true

        if onAdPlayableChanged then
            onAdPlayableChanged(true)
        end
    end

    function object:isAdPlayableByVungleSDK()
        log.debug("isAdPlayable")

        return isAdPlayable
    end

    function object:setOnAdPlayableChangedByVungleSDK(callback)
        log.debug("setOnAdPlayableChanged")

        onAdPlayableChanged = callback
    end

    return component
end

