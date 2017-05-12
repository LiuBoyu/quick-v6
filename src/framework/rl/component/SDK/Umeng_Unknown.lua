
local log = rl.log("SDK.Umeng")

----------------------------------------
-- 组件·SDK.Umeng(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Umeng(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:onEventByUmengSDK(e)
        log.debug("onEvent: %s", e)
    end

    function object:onLevelByUmengSDK(e)
        log.debug("onLevel: %s", e)
    end

    function object:onUserByUmengSDK(e)
        log.debug("onUser: %s", e)
    end

    function object:onPayByUmengSDK(e)
        log.debug("onPay: %s", e)
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

