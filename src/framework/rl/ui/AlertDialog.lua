
local AlertDialog = class("AlertDialog", function()
    return display.newNode()
end)

function AlertDialog:ctor(args)
    UI:Dialog(self, { mode = 3, effect = "FadeOut" })
        :addComponent("UI.Button")

    local args = args      or {}
    local text = args.text or ""

    -- 构建UI
    local AlertUI = G.Ctx:require("AlertUI")
    local alertUI

    if AlertUI then
        alertUI = AlertUI.new(args)
    else
        alertUI = display.newText({ text = text , size = 24, font = Font.Bold })
    end

    alertUI:align(display.CENTER, display.cx, display.cy):addTo(self)

    -- 自动消失
    self:performWithDelay(function()
        self:close()
    end, 3.0)

    -- 点击消失
    self:setOnTapOnce(function()
        self:close()
    end)

    -- 点击效果
    self:setOnPress()
    self:setOnRelease()

    -- 初始化
    self:init()
end

----------------------------------------
-- 配置
----------------------------------------

local height = 27

function AlertDialog.config(args)
    local args = args or {}

    height = args.height or height
end

----------------------------------------
-- 初始
----------------------------------------

local alerts = {}
local id = 1

local function reloadAll()
    local t = {}

    for k, v in pairs(alerts) do
        t[#t + 1] = k
    end

    table.sort(t)

    for i, k in ipairs(t) do
        local v = alerts[k]

        v:pos(0, (#t - i) * height)
    end
end

function AlertDialog:init()
    self.id = id
         id = id + 1

    alerts[self.id] = self
    reloadAll()

    self:addNodeEventListener(cc.NODE_EVENT, function(e)
        if e.name == "cleanup" then
            alerts[self.id] = nil
            reloadAll()
        end
    end)
end

return AlertDialog

