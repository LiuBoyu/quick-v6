
----------------------------------------
-- Net
----------------------------------------

local Net = class("Net")

----------------------------------------
-- 构建
----------------------------------------

function Net:ctor()
    Component(self)
        :addComponent("EventDispatcher")
        :addComponent("EventProxy")
end

return Net

