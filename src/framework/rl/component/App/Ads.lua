
----------------------------------------
-- 组件·广告 App.Ads
----------------------------------------

return function(object, args)

    local component = { id = "App.Ads" }

----------------------------------------
-- 组件依赖
----------------------------------------

    local args = args or {}

    if args.vungle then
        if not object:isComponent("SDK.Vungle") then object:addComponent("SDK.Vungle") end
    end

----------------------------------------
-- 对象方法·行为逻辑
----------------------------------------

    -- nothing

    return component
end

