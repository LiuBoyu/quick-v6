
----------------------------------------
-- System
----------------------------------------

local System = class("System")

----------------------------------------
-- 构建
----------------------------------------

function System:ctor()
    Component(self)
        :addComponent("SqliteModel", { table = "System", flush = { "Options.*", "Debug.*", "Others.*"} })
        :addComponent("EventProxy")

    scheduler.scheduleGlobal(function()
        self:flush()
    end, 1.0)
end

return System

