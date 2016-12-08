
local log = rl.log("SDK.IAP")

----------------------------------------
-- 组件·SDK.IAP(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.IAP(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local IAP = "org/cocos2dx/sdk/IAPSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:setOnPurchaseFinishedByIAPSDK(callback)
        log.debug("setOnPurchaseFinished")

        local callback = function(args) args = json.decode(args)
            return callback(args.ts)
        end

        local ok, ret = luaj.callStaticMethod(IAP, "setOnPurchaseFinished", {
                            callback,
                        }, "(I)V")
        return ret
    end

----------------------------------------
-- 对象方法
----------------------------------------

    local isSetupDone
    local isSetupBusy
    local setupResult

    local function startSetup(callback)
        log.debug("startSetup")

        if isSetupBusy then
            return callback({ code = -1 })
        end

        if isSetupDone then
            return callback(nil, setupResult)
        end

        isSetupBusy = true

        local callback = function(args) args = json.decode(args)
            isSetupBusy = nil

            if not args.e then
                isSetupDone = true
                setupResult = nil
            end

            return callback(args.e, setupResult)
        end

        local ok, ret = luaj.callStaticMethod(IAP, "startSetup", {
                            callback,
                        }, "(I)V")
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

        local callback = function(args) args = json.decode(args)
            isQueryInventoryBusy = nil

            if not args.e then
                isQueryInventoryDone = true
                queryInventoryResult = { consumableProducts = args.consumableProducts, nonConsumableProducts = args.nonConsumableProducts, invalidIds = args.invalidIds }
            end

            return callback(args.e, queryInventoryResult)
        end

        local consumableProductIds    = rl.G.IapConsumableProductIds    or {}
        local nonConsumableProductIds = rl.G.IapNonConsumableProductIds or {}

        local ok, ret = luaj.callStaticMethod(IAP, "queryInventory", {
                            consumableProductIds, nonConsumableProductIds, callback,
                        }, "(Ljava/util/ArrayList;Ljava/util/ArrayList;I)V")
        return ret
    end

----------------------------------------
-- 对象方法
----------------------------------------

    function object:initByIAPSDK(callback)
        log.debug("init")

        local callback = callback or function(isOK, info) end

        startSetup(function(e, res) if e then return callback(false) end
            queryInventory(function(e, res) if e then return callback(false) end
                return callback(true, res)
            end)
        end)
    end

    function object:isInitDoneByIAPSDK()
        return (isQueryInventoryDone and isSetupDone)
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
                local ok, ret = luaj.callStaticMethod(IAP, "purchaseConsumable", {
                                    id,
                                }, "(Ljava/lang/String;)V")
                return ret
            end
        end)
    end

    return component
end

