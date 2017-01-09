
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
    local VungleSDK = "org/cocos2dx/sdk/VungleSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:playAdByVungleSDK(callback)
        log.debug("playAd")

        local callback = function(args) args = json.decode(args)
            if callback then
                return callback(args)
            end
        end

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

        local callback = function(args) args = (args == "TRUE") and true or false
            if callback then
                return callback(args)
            end
        end

        local ok, ret = luaj.callStaticMethod(VungleSDK, "setOnAdPlayableChanged", {
                            callback,
                        }, "(I)V")
        return ret
    end

    return component
end

