
local log = rl.log("SDK.IAP")

----------------------------------------
-- 组件·SDK.IAP(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.IAP(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local onPurchaseFinished = function(ts) end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:setOnPurchaseFinishedByIAPSDK(callback)
        log.debug("setOnPurchaseFinished")

        onPurchaseFinished = callback
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:initByIAPSDK(callback)
        log.debug("init")

        local callback = callback or function(isOK, info) end
        return callback(true, {})
    end

    function object:isInitDoneByIAPSDK()
        return true
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:purchaseByIAPSDK(id)
        log.debug("purchase: %s", { id = id })

        onPurchaseFinished({ state = "Purchased", productId = id, receipt = "debug" })
    end

    return component
end

