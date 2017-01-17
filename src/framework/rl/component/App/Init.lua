
----------------------------------------
-- 组件·应用 App.Init
----------------------------------------

return function(object)

    local component = { id = "App.Init" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("SDK.App") then object:addComponent("SDK.App") end

----------------------------------------
-- 组件方法·转发事件(Cocos)
----------------------------------------

    local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT", function()

        object:dispatchEvent("APP_ENTER_FOREGROUND")

    end)
    local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT", function()

        object:dispatchEvent("APP_ENTER_BACKGROUND")

    end)

    local dispatcher = cc.Director:getInstance():getEventDispatcher()

    dispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)
    dispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)

    return component
end

