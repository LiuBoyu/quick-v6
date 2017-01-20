
----------------------------------------
-- System
----------------------------------------

local System = class("System")

----------------------------------------
-- 构建
----------------------------------------

function System:ctor()
    Component(self)
        :addComponent("SqliteModel", { table = "System", flush = { "Options.*", "Debug.*" } })
        :addComponent("EventProxy")
end

return System

