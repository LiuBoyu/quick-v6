
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

    -- App
    self:listenEvent(self, "APP_INIT", function(e)
        G.System:incr("Options.App.Init")
    end)

    -- IAP
    self:listenEvent(self, "IAP_TRY_TO_PURCHASE", function(e)
    end)
    self:listenEvent(self, "IAP_PURCHASED"      , function(e)
        G.System:incr("Options.Iap.Purchased")
        G.System:flush()
    end)
    self:listenEvent(self, "IAP_CANCELLED"      , function(e)
    end)
    self:listenEvent(self, "IAP_FAILED"         , function(e)
        device.showAlert("IAP Failed", "", { "OK" })
    end)

    -- Ads
    self:listenEvent(self, "ADS_TRY_TO_PLAY"   , function(e)
    end)
    self:listenEvent(self, "ADS_PLAY_COMPLETED", function(e)
        G.System:incr("Options.Ads.Played")
    end)
    self:listenEvent(self, "ADS_PLAY_CANCELLED", function(e)
    end)
    self:listenEvent(self, "ADS_PLAY_FAILED"   , function(e)
    end)

    -- Analytics
    self:track("APP_INIT"               , function(e) return "event", { id = "APP0" } end)
    self:track("IAP_TRY_TO_PURCHASE"    , function(e) return "event", { id = "IAP0" } end)
    self:track("IAP_PURCHASED"          , function(e) return "event", { id = "IAP1" } end)
    self:track("IAP_CANCELLED"          , function(e) return "event", { id = "IAP2" } end)
    self:track("IAP_FAILED"             , function(e) return "event", { id = "IAP3" } end)
    self:track("ADS_TRY_TO_PLAY"        , function(e) return "event", { id = "ADS0" } end)
    self:track("ADS_PLAY_COMPLETED"     , function(e) return "event", { id = "ADS1" } end)
    self:track("ADS_PLAY_CANCELLED"     , function(e) return "event", { id = "ADS2" } end)
    self:track("ADS_PLAY_FAILED"        , function(e) return "event", { id = "ADS3" } end)

    -- System
    scheduler.scheduleGlobal(function()
        G.System:flush()
    end, 1.0)

    -- 初始化·完成
    self:dispatchEvent("APP_INIT")
end

return App

