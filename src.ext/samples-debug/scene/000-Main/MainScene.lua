
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor(args)
    UI:DebugScene(self, args)

    self:MENU("Scene")

    self:MENU("Dialog")

    self:MENU("UI")

    self:MENU("Other")

    self:TEST("Net",     function() G.Ctx:goto("@@Net")     end)
    self:TEST("Sdk",     function() G.Ctx:goto("@@Sdk")     end)
    self:TEST("Util",    function() G.Ctx:goto("@@Util")    end)
    self:TEST("Samples", function() G.Ctx:goto("@@Samples") end)
end

return M

