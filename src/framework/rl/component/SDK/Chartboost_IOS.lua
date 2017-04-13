
local log = rl.log("SDK.Chartboost")

----------------------------------------
-- 组件·ChartboostSDK(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Chartboost(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:playAdByChartboostSDK(callback)
        log.debug("playAd")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "playAdByChartboostSDK",{
                            callback = callback,
                        })
        return ret
    end

    function object:isAdPlayableByChartboostSDK()
        log.debug("isAdPlayable")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "isAdPlayableByChartboostSDK")
        return ret
    end

    function object:setOnAdPlayableChangedByChartboostSDK(callback)
        log.debug("setOnAdPlayableChanged")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "setOnAdPlayableChangedByChartboostSDK", {
                            callback = callback,
                        })
        return ret
    end

    function object:playItByChartboostSDK()
        log.debug("playIt")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "playItByChartboostSDK")
        return ret
    end

    function object:isItPlayableByChartboostSDK()
        log.debug("isItPlayable")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "isItPlayableByChartboostSDK")
        return ret
    end

    function object:setOnItPlayableChangedByChartboostSDK(callback)
        log.debug("setOnItPlayableChanged")

        local ok, ret = luaoc.callStaticMethod("SDKApp", "setOnItPlayableChangedByChartboostSDK", {
                            callback = callback,
                        })
        return ret
    end

    return component
end

