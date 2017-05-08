
----------------------------------------
-- 组件·广告 App.Ads
----------------------------------------

return function(object, args)

    local component = { id = "App.Ads" }

----------------------------------------
-- 组件依赖
----------------------------------------

    local args = args or {}

    if args.vungle     then
        if not object:isComponent("SDK.Vungle")     then object:addComponent("SDK.Vungle")     end
    end

    if args.chartboost then
        if not object:isComponent("SDK.Chartboost") then object:addComponent("SDK.Chartboost") end
    end

----------------------------------------
-- 对象方法·行为逻辑
----------------------------------------

    function object:playAd(callback)
        local isOK

        local callback = function(ret)

            if ret.error then
                    self:dispatchEvent("ADS_PLAY_FAILED"   , ret)
            else
                if ret.isCompleted then
                    self:dispatchEvent("ADS_PLAY_COMPLETED", ret)
                else
                    self:dispatchEvent("ADS_PLAY_CANCELLED", ret)
                end
            end

            if callback then
                return callback(ret)
            end
        end

        self:dispatchEvent("ADS_TRY_TO_PLAY")

        if not isOK and args.chartboost then
            if self:isAdPlayableByChartboostSDK() then
                self:playAdByChartboostSDK(function(ret)
                    return callback({ isCompleted = ret.wasSuccessfulView, error = ret.reason })
                end)
                isOK = true
            end
        end

        if not isOK and args.vungle then
            if self:isAdPlayableByVungleSDK() then
                self:playAdByVungleSDK(function(ret)
                    return callback({ isCompleted = ret.wasSuccessfulView, error = ret.reason })
                end)
                isOK = true
            end
        end

        if not isOK then
            return callback({ error = "unavailable" })
        end
    end

    function object:isAdPlayable()
        if self:isAdPlayableByVungleSDK() then return true end
    end

    function object:playIt()
        local isOK

        if not isOK and args.chartboost then
            if self:isItPlayableByChartboostSDK() then
                self:playItByChartboostSDK()
                isOK = true
            end
        end

        if not isOK and args.vungle then
            if self:isAdPlayableByVungleSDK() then
                self:playAdByVungleSDK(function(ret)
                    -- nothing
                end)
                isOK = true
            end
        end

        if isOK then
            self:dispatchEvent("ADS_PLAY_IT")
        end

        return isOK
    end

    function object:isItPlayable()
        if args.chartboost and self:isItPlayableByChartboostSDK() then return true end
        if args.vungle     and self:isAdPlayableByVungleSDK()     then return true end
    end

    return component
end

