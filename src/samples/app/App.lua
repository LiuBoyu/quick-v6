
----------------------------------------
-- App
----------------------------------------

local App = class("App")

----------------------------------------
-- 构建
----------------------------------------

function App:ctor()
    Component(self)
        :addComponent("EventDispatcher")
        :addComponent("EventProxy")
        :addComponent("SDK.App")
        :addComponent("SDK.Vungle")

    -- 转发事件(Cocos)
    local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT", function()

        self:dispatchEvent("APP_ENTER_FOREGROUND")

    end)
    local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT", function()

        self:dispatchEvent("APP_ENTER_BACKGROUND")

    end)

    local dispatcher = cc.Director:getInstance():getEventDispatcher()

    dispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)
    dispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
end

return App

