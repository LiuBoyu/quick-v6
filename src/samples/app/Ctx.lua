
----------------------------------------
-- Ctx
----------------------------------------

local Ctx = class("Ctx")

----------------------------------------
-- 构建
----------------------------------------

function Ctx:ctor()
    Component(self)
        :addComponent("EventDispatcher")
        :addComponent("EventProxy")
        :addComponent("Ctx.Init")
        :addComponent("Ctx.Dialog")
end

----------------------------------------
-- Goto
----------------------------------------

function Ctx:gotoMain()
    return self:goto("Main")
end

return Ctx

