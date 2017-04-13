
local log = rl.log("SDK.Chartboost")

----------------------------------------
-- 组件·ChartboostSDK(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Chartboost(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local ChartboostSDK = "org/cocos2dx/sdk/ChartboostSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:playAdByChartboostSDK(callback)
        log.debug("playAd")

        local callback = function(args) args = json.decode(args)
            if callback then
                return callback(args)
            end
        end

        local ok, ret = luaj.callStaticMethod(ChartboostSDK, "playAd", {
                            callback,
                        }, "(I)V")
        return ret
    end

    function object:isAdPlayableByChartboostSDK()
        log.debug("isAdPlayable")

        local ok, ret = luaj.callStaticMethod(ChartboostSDK, "isAdPlayable", {
                        }, "()Z")
        return ret
    end

    function object:setOnAdPlayableChangedByChartboostSDK(callback)
        log.debug("setOnAdPlayableChanged")

        local callback = function(args) args = (args == "TRUE") and true or false
            if callback then
                return callback(args)
            end
        end

        local ok, ret = luaj.callStaticMethod(ChartboostSDK, "setOnAdPlayableChanged", {
                            callback,
                        }, "(I)V")
        return ret
    end

    function object:playItByChartboostSDK()
        log.debug("playIt")

        local ok, ret = luaj.callStaticMethod(ChartboostSDK, "playIt", {
                        }, "()V")
        return ret
    end

    function object:isItPlayableByChartboostSDK()
        log.debug("isItPlayable")

        local ok, ret = luaj.callStaticMethod(ChartboostSDK, "isItPlayable", {
                        }, "()Z")
        return ret
    end

    function object:setOnItPlayableChangedByChartboostSDK(callback)
        log.debug("setOnItPlayableChanged")

        local callback = function(args) args = (args == "TRUE") and true or false
            if callback then
                return callback(args)
            end
        end

        local ok, ret = luaj.callStaticMethod(ChartboostSDK, "setOnItPlayableChanged", {
                            callback,
                        }, "(I)V")
        return ret
    end

    return component
end

