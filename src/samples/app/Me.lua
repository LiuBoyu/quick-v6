
----------------------------------------
-- Me
----------------------------------------

local Me = class("Me")

----------------------------------------
-- 构建
----------------------------------------

function Me:ctor()
    Component(self)
        :addComponent("SqliteModel", { table = "Me" })
        :addComponent("EventProxy")
end

return Me

