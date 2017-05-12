
local log = rl.log("SDK.Umeng")

----------------------------------------
-- 组件·SDK.Umeng(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Umeng(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local UmengSDK = "org/cocos2dx/sdk/UmengSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:onEventByUmengSDK(e)
        log.debug("onEvent: %s", e)

        local ok, ret = luaj.callStaticMethod(UmengSDK, "onEvent", {
                            json.encode({ id = e.id, kv = e.kv, du = e.ct })
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onLevelByUmengSDK(e)
        log.debug("onLevel: %s", e)

        local ok, ret = luaj.callStaticMethod(UmengSDK, "onLevel", {
                            json.encode({ cmd = e.cmd, level = e.level })
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onUserByUmengSDK(e)
        log.debug("onUser: %s", e)

        local ok, ret = luaj.callStaticMethod(UmengSDK, "onUser", {
                            json.encode({ cmd = e.cmd, playerID = e.playerID, provider = e.provider, level = e.level })
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onPayByUmengSDK(e)
        log.debug("onPay: %s", e)

        if     e.source == "GooglePlay" then e.source = 1
        elseif e.source == "AppleStore" then e.source = 1
        else                                 e.source = 1
        end

        local ok, ret = luaj.callStaticMethod(UmengSDK, "onPay", {
                            json.encode({ cmd = e.cmd, cash = e.cash, coin = e.coin, item = e.item, amount = e.amount, price = e.price, source = e.source })
                        }, "(Ljava/lang/String;)V")
        return ret
    end

    function object:onBuyByUmengSDK(e)
        log.debug("onBuy: %s", e)
    end

    function object:onUseByUmengSDK(e)
        log.debug("onUse: %s", e)
    end

    function object:onBonusByUmengSDK(e)
        log.debug("onBonus: %s", e)
    end

    return component
end

