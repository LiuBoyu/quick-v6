
local log = rl.log("SDK.Chartboost")

----------------------------------------
-- 组件·ChartboostSDK(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Chartboost(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local isAdPlayable = true
    local onAdPlayableChanged

    local isItPlayable = true
    local onItPlayableChanged

----------------------------------------
-- 对象方法
----------------------------------------

    function object:playAdByChartboostSDK(callback)
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

    function object:isAdPlayableByChartboostSDK()
        log.debug("isAdPlayable")

        return isAdPlayable
    end

    function object:setOnAdPlayableChangedByChartboostSDK(callback)
        log.debug("setOnAdPlayableChanged")

        onAdPlayableChanged = callback
    end

    function object:playItByChartboostSDK()
        log.debug("playIt")

        isItPlayable = false

        if onItPlayableChanged then
            onItPlayableChanged(false)
        end

        isItPlayable = true

        if onItPlayableChanged then
            onItPlayableChanged(true)
        end
    end

    function object:isItPlayableByChartboostSDK()
        log.debug("isItPlayable")

        return isItPlayable
    end

    function object:setOnItPlayableChangedByChartboostSDK(callback)
        log.debug("setOnItPlayableChanged")

        onItPlayableChanged = callback
    end

    return component
end

