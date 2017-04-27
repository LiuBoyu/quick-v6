
local log = rl.log("SDK.IAP")

----------------------------------------
-- 组件·SDK.IAP(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.IAP(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:setOnPurchaseFinishedByIAPSDK(callback)
        log.debug("setOnPurchaseFinished")

        local ok, ret = luaoc.callStaticMethod("SDKIAP", "init",  {
                                    callback   = callback,
                        })
        return ret
    end

----------------------------------------
-- 对象方法
----------------------------------------

    local isQueryInventoryDone
    local isQueryInventoryBusy
    local queryInventoryResult

    local function queryInventory(callback)
        log.debug("queryInventory")

        if isQueryInventoryBusy then
            return callback({ code = -1 })
        end

        if isQueryInventoryDone then
            return callback(nil, queryInventoryResult)
        end

        isQueryInventoryBusy = true

        local callback = function(products, invalidIds, e)
            isQueryInventoryBusy = nil

            if not e then
                isQueryInventoryDone = true

                luaoc.callStaticMethod("SDKIAP", "loadStore")

                -- fixme
                queryInventoryResult = { consumableProducts = products, nonConsumableProducts = nil, invalidIds = invalidIds }
            end

            return callback(e, queryInventoryResult)
        end

        local consumableProductIds    = rl.G.IapConsumableProductIds    or {}
        local nonConsumableProductIds = rl.G.IapNonConsumableProductIds or {}

        local productIds = {}

        for _, v in ipairs(   consumableProductIds) do
            productIds[#productIds+1] = v
        end
        for _, v in ipairs(nonConsumableProductIds) do
            productIds[#productIds+1] = v
        end

        local ok, ret = luaoc.callStaticMethod("SDKIAP", "loadProducts",  {
                                    productIds = productIds and json.encode(productIds) or nil,
                                    callback   = callback,
                        })
        return ret
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:initByIAPSDK(callback)
        log.debug("init")

        local callback = callback or function(isOK, info) end
        queryInventory(function(e, res)
            if e then return callback(false) end
            return callback(true, res)
        end)
    end

    function object:isInitDoneByIAPSDK()
        return isQueryInventoryDone
    end

----------------------------------------
-- 对象方法
----------------------------------------

    local function checkInitDone(callback)
        if object:isInitDoneByIAPSDK() then
            return callback(true)
        end

        object:initByIAPSDK(function(isOK, info)
            return callback(isOK)
        end)
    end

    function object:purchaseByIAPSDK(id)
        checkInitDone(function(isOK)
            log.debug("purchase: %s", { isOK = isOK, id = id })

            if isOK then
                local ok, ret = luaoc.callStaticMethod("SDKIAP", "purchase",  {
                                    productId = id,
                                })
                return ret
            end
        end)
    end

    return component
end

