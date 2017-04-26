
----------------------------------------
-- 组件·分析 App.Analytics
----------------------------------------

return function(object, args)

    local component = { id = "App.Analytics" }

----------------------------------------
-- 组件依赖
----------------------------------------

    local args = args or {}

    if args.umeng then
        if not object:isComponent("SDK.Umeng") then object:addComponent("SDK.Umeng") end
    end

----------------------------------------
-- 对象方法·事件统计
----------------------------------------

    function object:track(name, callback)
        self:listenEvent(self, name, function(e)
            local k, v = callback(e)

            if v then

                if k == "event" then
                    if args.umeng then
                        object:onEventByUmengSDK(v)
                    end
                end

            end
        end)
    end

    function object:reportError(msg)
        -- todo
    end

    function object:trackUser(name, callback)
        self:listenEvent(self, name, function(e)
            local k, v = callback(e)

            if v then

                if k == "login"  then
                    if args.umeng then
                        object:onUserByUmengSDK({ cmd = "login", playerID = v.playerID, provider = v.provider })
                    end
                end

                if k == "logout" then
                    if args.umeng then
                        object:onUserByUmengSDK({ cmd = "logout" })
                    end
                end

                if k == "level"  then
                    if args.umeng then
                        object:onUserByUmengSDK({ cmd = "level", level = v.level })
                    end
                end

            end
        end)
    end

    function object:trackPay(name, callback)
        self:listenEvent(self, name, function(e)
            local k, v = callback(e)

            if v then

                if k == "coin"  then
                    if args.umeng then
                        object:onPayByUmengSDK({ cmd = "coin", cash = v.cash, coin = v.coin, source = v.source })
                    end
                end

                if k == "item" then
                    if args.umeng then
                        object:onPayByUmengSDK({ cmd = "item", cash = v.cash, item = v.item, amount = v.amount, price = v.price, source = v.source })
                    end
                end

            end
        end)
    end

    function object:trackBuy()
    end
    function object:trackUse()
    end
    function object:trackBonus()
    end
    function object:trackLevel(name, callback)
        self:listenEvent(self, name, function(e)
            local k, v = callback(e)

            if v then

                if k == "start"  then
                    if args.umeng then
                        object:onLevelByUmengSDK({ cmd = "start" , level = v.level })
                    end
                end

                if k == "finish" then
                    if args.umeng then
                        object:onLevelByUmengSDK({ cmd = "finish", level = v.level })
                    end
                end

                if k == "fail"   then
                    if args.umeng then
                        object:onLevelByUmengSDK({ cmd = "fail"  , level = v.level })
                    end
                end

            end
        end)
    end

    return component
end

