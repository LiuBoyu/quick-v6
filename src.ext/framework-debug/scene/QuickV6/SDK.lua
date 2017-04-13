
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor()
    UI:DebugScene(self)

    ----------------
    -- App
    ----------------

    self:MENU("App")

    self:TEST("appInfo", function()
        print(tostring(G.App:getAppInfo()))
        print(tostring(G.App:getDevInfo()))
        print(tostring(G.App:getUdid()))
        print(tostring(G.App:getUuid()))
    end)

    self:TEST("mailto", function()
        G.App:mailto({
            recipient = "nobody@abc.com",
            subject   = "Hello World!!!",
            body      = "Hello World!!!",
        })
    end)

    self:TEST("openUrl", function()
        G.App:openUrl("http://www.baidu.com/")
    end)

    ----------------
    -- IAP
    ----------------

    self:MENU("IAP", { newline = false })

    self:TEST("init", function()
        G.App:initByIAPSDK(function(isOK, info)
            print(tostring(isOK))
            print(tostring(info))
        end)
    end)

    self:TEST("purchase", function()
        G.App:purchaseByIAPSDK( G.Config.IAP[1].iap )
    end)

    self:TEST("onPurchaseFinished", function()
        G.App:setOnPurchaseFinishedByIAPSDK(function(ts)
            print(tostring("OnPurchaseFinishedByIAP"))
            print(tostring(ts))
        end)
    end)

    ----------------
    -- Vungle
    ----------------

    self:MENU("Vungle", { newline = false })

    self:TEST("playAd", function()
        G.App:playAdByVungleSDK(function(ret)
            print("playAd:", tostring(ret))
        end)
    end)

    self:TEST("isAdPlayable", function()
        print("isAdPlayable: ", G.App:isAdPlayableByVungleSDK())
    end)

    self:TEST("onAdPlayableChanged", function()
        G.App:setOnAdPlayableChangedByVungleSDK(function(isOK)
            print("onAdPlayableChanged:", isOK)
        end)
    end)

    ----------------
    -- Chartboost
    ----------------

    self:MENU("Chartboost", { newline = false })

    self:TEST("playAd", function()
        G.App:playAdByChartboostSDK(function(ret)
            print("playAd:", tostring(ret))
        end)
    end)

    self:TEST("isAdPlayable", function()
        print("isAdPlayable: ", G.App:isAdPlayableByChartboostSDK())
    end)

    self:TEST("onAdPlayableChanged", function()
        G.App:setOnAdPlayableChangedByChartboostSDK(function(isOK)
            print("onAdPlayableChanged:", isOK)
        end)
    end)

    self:TEST("playIt", function()
        G.App:playItByChartboostSDK()
    end)

    self:TEST("isItPlayable", function()
        print("isItPlayable: ", G.App:isItPlayableByChartboostSDK())
    end)

    self:TEST("onItPlayableChanged", function()
        G.App:setOnItPlayableChangedByChartboostSDK(function(isOK)
            print("onItPlayableChanged:", isOK)
        end)
    end)

end

return M

