
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

    local onEvent = function(e)
        if args.umeng then
            object:onEventByUmengSDK(e)
        end
    end

    function object:track(name)
        self:listenEvent(self, name, onEvent)
    end

    return component
end

