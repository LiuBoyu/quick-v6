
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor()
    UI:DebugScene(self)

    self:MENU("QuickV6")

    self:TEST("Component", function() G.Ctx:goto("@@QuickV6.Component") end)
    self:TEST("App"      , function() G.Ctx:goto("@@QuickV6.App")       end)
    self:TEST("Ctx"      , function() G.Ctx:goto("@@QuickV6.Ctx")       end)
    self:TEST("SDK"      , function() G.Ctx:goto("@@QuickV6.SDK")       end)
    self:TEST("UI"       , function() G.Ctx:goto("@@QuickV6.UI")        end)
    self:TEST("Http"     , function() G.Ctx:goto("@@QuickV6.Http")      end)
    self:TEST("Websocket", function() G.Ctx:goto("@@QuickV6.Websocket") end)
    self:TEST("Features" , function() G.Ctx:goto("@@QuickV6.Features")  end)
    self:TEST("Utils"    , function() G.Ctx:goto("@@QuickV6.Utils")     end)

end

return M

