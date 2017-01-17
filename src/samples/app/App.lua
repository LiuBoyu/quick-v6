
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
        :addComponent("App.Init")
        :addComponent("App.Ads", { vungle = true })
        :addComponent("App.Analytics", { umeng = true })
        :addComponent("App.IAP")
end

function App:init()
    -- 初始化·开始

    -- App
    self:listenEvent(self, "APP_ENTER_FOREGROUND", function(e)
    end)
    self:listenEvent(self, "APP_ENTER_BACKGROUND", function(e)
    end)

    -- IAP
    self:listenEvent(self, "IAP_PURCHASED", function(e)
    end)
    self:listenEvent(self, "IAP_CANCELLED", function(e)
    end)
    self:listenEvent(self, "IAP_FAILED", function(e)
        device.showAlert("IAP Failed", "", { "OK" })
    end)

    -- Analytics
    self:track("APP_INIT")

    -- System
    scheduler.scheduleGlobal(function()
        G.System:flush()
    end, 1.0)

    -- 初始化·完成
    self:dispatchEvent("APP_INIT")
end

return App

