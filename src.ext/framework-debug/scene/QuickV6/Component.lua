
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor()
    UI:DebugScene(self)

    local aaa = Component({}, { class = "SimpleModel" }):addComponent("SimpleModel")

    G.Ctx:createSimpleModelUI(aaa)
        :align(display.CENTER, display.cx-200, 100)
        :scale(0.8)
        :addTo(self)

    self:MENU("SimpleModel")

    self:TEST("set", function()
        aaa:set("obj.ct", 0)
        aaa:set("obj.ts", gettime())
    end)
    self:TEST("incr", function()
        aaa:incr("obj.ct")
        aaa:incr("obj.ts", 100)
    end)
    self:TEST("decr", function()
        aaa:decr("obj.ct")
        aaa:decr("obj.ts", 100)
    end)

    self:TEST("hset", function()
        aaa:hset("obj", "ct", 0)
        aaa:hset("obj", "ts", gettime())
    end)

    self:MENU("SqliteModel")

end

return M

