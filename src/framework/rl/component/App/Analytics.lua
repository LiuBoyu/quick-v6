
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

    return component
end

