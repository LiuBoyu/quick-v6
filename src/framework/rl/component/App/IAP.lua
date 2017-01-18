
----------------------------------------
-- 组件·支付 App.IAP
----------------------------------------

return function(object, args)

    local component = { id = "App.IAP" }

----------------------------------------
-- 组件依赖
----------------------------------------

    local args = args or {}

    if not object:isComponent("SDK.IAP") then object:addComponent("SDK.IAP") end

----------------------------------------
-- 对象方法·商品初始化
----------------------------------------

    local data = G.Config.IAP

    for i, v in ipairs(data) do
        if PLATFORM_IOS     then
            v.iap = v.applestore
        end
        if PLATFORM_ANDROID then
            v.iap = v.googleplay
        end
        if PLATFORM_UNKNOWN then
            v.iap = v.id
        end
    end

    local allIAPs = {}

    for i, v in ipairs(data) do
        if v.iap then
            allIAPs[#allIAPs+1] = v.iap
        end
    end

    rl.G.IapConsumableProductIds = allIAPs

----------------------------------------
-- 对象方法·商品获取
----------------------------------------

    function object:getProductByIAP(iap)
        for i, v in ipairs(data) do
            if v.iap == iap then
                return v
            end
        end
    end

    function object:getProductById(id)
        for i, v in ipairs(data) do
            if v.id == id then
                return v
            end
        end
    end

----------------------------------------
-- 组件方法·支付校验
----------------------------------------

    local function verifyReceipt(ts, callback)
        object:logINFO("支付校验: ... %s", ts)

        local receipt = ts.receipt
        local store   = "debug"

        if PLATFORM_IOS     then
            store = "applestore"
        end
        if PLATFORM_ANDROID then
            store = "googleplay"
        end

        return callback(nil, {})
    end

----------------------------------------
-- 组件方法·支付回调
----------------------------------------

    object:setOnPurchaseFinishedByIAPSDK(function(ts)
        if ts.state == "Purchased" then
            verifyReceipt(ts, function(e, data)
                if e then
                    object:logWARN("支付交易 ... 失败[%s]", ts)
                    object:dispatchEvent("IAP_FAILED",    { ts = ts })
                else
                    object:logINFO("支付交易 ... 成功[%s]", ts)
                    object:dispatchEvent("IAP_PURCHASED", { ts = ts })
                end
            end)
        end

        if ts.state == "Cancelled" then
            object:logINFO("支付交易 ... 取消[%s]", ts)
            object:dispatchEvent("IAP_CANCELLED", { ts = ts })
        end

        if ts.state == "Failed"    then
            object:logWARN("支付交易 ... 失败[%s]", ts)
            object:dispatchEvent("IAP_FAILED",    { ts = ts })
        end
    end)

----------------------------------------
-- 组件方法·初始化
----------------------------------------

    object:initByIAPSDK(function(isOK, info)
        if isOK then
            if PLATFORM_UNKNOWN then
                info.consumableProducts = data
            end
            for i, v in ipairs(info.consumableProducts or {}) do

                local ret = object:getProductByIAP(v.id)

                if ret then
                    ret.price = v.price
                    ret.isOK  = true
                end

            end
            object:logDEBUG("商品清单: %s", data)
        end
    end)

----------------------------------------
-- 对象方法·内购支付
----------------------------------------

    function object:purchase(id)
        object:logINFO("支付交易: %s", id)

        local ret = self:getProductById(id)

        if not ret then
            return object:logWARN("支付交易: ... 失败[id=%s]", id)
        end

        local isOK = ret.isOK

        if not isOK then
            return object:logWARN("支付交易: ... 失败[id=%s]", id)
        end

        object:dispatchEvent("IAP_TRY_TO_PURCHASE", ret)
        object:purchaseByIAPSDK(ret.iap)
    end

    return component
end

