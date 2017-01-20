
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor(args)
    UI:DebugScene(self, args)

    self:MENU("Scene")
    self:TEST("Main",       function() G.Ctx:goto("Main")      end)

    self:MENU("Other")
    self:TEST("QuickV6",    function() G.Ctx:goto("@@QuickV6") end)

end

return M

