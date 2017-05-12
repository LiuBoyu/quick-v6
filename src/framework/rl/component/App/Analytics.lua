
----------------------------------------
-- 组件·分析 App.Analytics
----------------------------------------

return function(object, args)

    local component = { id = "App.Analytics" }

----------------------------------------
-- 组件依赖
----------------------------------------

    local args = args or {}

    if args.umeng       then
        if not object:isComponent("SDK.Umeng")       then object:addComponent("SDK.Umeng")       end
    end

    if args.talkingdata then
        if not object:isComponent("SDK.TalkingData") then object:addComponent("SDK.TalkingData") end
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
                    if args.umeng       then
                        object:onUserByUmengSDK      ({ cmd = "login", playerID = v.playerID, level = v.level, provider = v.provider })
                    end
                    if args.talkingdata then
                        object:onUserByTalkingDataSDK({ cmd = "login", playerID = v.playerID, level = v.level, provider = v.provider })
                    end
                end

                if k == "logout" then
                    if args.umeng       then
                        object:onUserByUmengSDK      ({ cmd = "logout" })
                    end
                    if args.talkingdata then
                        object:onUserByTalkingDataSDK({ cmd = "logout" })
                    end
                end

                if k == "level"  then
                    if args.umeng       then
                        object:onUserByUmengSDK      ({ cmd = "level", playerID = v.playerID, level = v.level })
                    end
                    if args.talkingdata then
                        object:onUserByTalkingDataSDK({ cmd = "level", playerID = v.playerID, level = v.level })
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
                    if args.umeng       then
                        object:onPayByUmengSDK      ({ cmd = "coin", cash = v.cash, coin = v.coin,                                     source = v.source, orderId = v.orderId, iapId = v.iapId })
                    end
                    if args.talkingdata then
                        object:onPayByTalkingDataSDK({ cmd = "coin", cash = v.cash, coin = v.coin,                                     source = v.source, orderId = v.orderId, iapId = v.iapId })
                    end
                end

                if k == "item" then
                    if args.umeng       then
                        object:onPayByUmengSDK      ({ cmd = "item", cash = v.cash, item = v.item, amount = v.amount, price = v.price, source = v.source, orderId = v.orderId, iapId = v.iapId })
                    end
                    if args.talkingdata then
                        object:onPayByTalkingDataSDK({ cmd = "item", cash = v.cash, item = v.item, amount = v.amount, price = v.price, source = v.source, orderId = v.orderId, iapId = v.iapId })
                    end
                end

            end
        end)
    end

    function object:trackItem(name, callback)
        self:listenEvent(self, name, function(e)
            local k, v = callback(e)

            if v then

                if k == "buy"  then
                    if args.umeng       then
                        object:onBuyByUmengSDK      ({ item = v.item, amount = v.amount, price = v.price })
                    end
                    if args.talkingdata then
                        object:onBuyByTalkingDataSDK({ item = v.item, amount = v.amount, price = v.price })
                    end
                end

                if k == "use" then
                    if args.umeng       then
                        object:onUseByUmengSDK      ({ item = v.item, amount = v.amount, price = v.price })
                    end
                    if args.talkingdata then
                        object:onUseByTalkingDataSDK({ item = v.item, amount = v.amount, price = v.price })
                    end
                end

                if k == "buy&use" then
                    if args.umeng       then
                        object:onBuyByUmengSDK      ({ item = v.item, amount = v.amount, price = v.price })
                        object:onUseByUmengSDK      ({ item = v.item, amount = v.amount, price = v.price })
                    end
                    if args.talkingdata then
                        object:onBuyByTalkingDataSDK({ item = v.item, amount = v.amount, price = v.price })
                        object:onUseByTalkingDataSDK({ item = v.item, amount = v.amount, price = v.price })
                    end
                end

            end
        end)
    end

    function object:trackBonus(name, callback)
        self:listenEvent(self, name, function(e)
            local k, v = callback(e)

            if v then

                if k == "coin" then
                    if args.umeng       then
                        object:onBonusByUmengSDK      ({ cmd = "coin", coin = v.coin, reason = v.reason })
                    end
                    if args.talkingdata then
                        object:onBonusByTalkingDataSDK({ cmd = "coin", coin = v.coin, reason = v.reason })
                    end
                end

            end
        end)
    end

    function object:trackLevel(name, callback)
        self:listenEvent(self, name, function(e)
            local k, v = callback(e)

            if v then

                if k == "start"  then
                    if args.umeng       then
                        object:onLevelByUmengSDK      ({ cmd = "start" , level = v.level })
                    end
                    if args.talkingdata then
                        object:onLevelByTalkingDataSDK({ cmd = "start" , level = v.level })
                    end
                end

                if k == "finish" then
                    if args.umeng       then
                        object:onLevelByUmengSDK      ({ cmd = "finish", level = v.level })
                    end
                    if args.talkingdata then
                        object:onLevelByTalkingDataSDK({ cmd = "finish", level = v.level })
                    end
                end

                if k == "fail"   then
                    if args.umeng       then
                        object:onLevelByUmengSDK      ({ cmd = "fail"  , level = v.level, cause = v.cause })
                    end
                    if args.talkingdata then
                        object:onLevelByTalkingDataSDK({ cmd = "fail"  , level = v.level, cause = v.cause })
                    end
                end

            end
        end)
    end

    return component
end

