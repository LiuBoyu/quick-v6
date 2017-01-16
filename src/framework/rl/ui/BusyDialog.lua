
local BusyDialog = class("BusyDialog", function()
    return display.newNode()
end)

function BusyDialog:ctor(args)
    UI:Dialog(self, { mode = 2, effect = "None", bgcolor = {0,0,0,63} })

    local args = args      or {}
    local name = args.name or ""

    -- 构建UI
    local BusyUI = G.Ctx:require("BusyUI")
    local busyUI

    if BusyUI then
        busyUI = BusyUI.new(args)
    else
        busyUI = display.newNode()
    end

    busyUI:align(display.CENTER, 0, 0):addTo(self)

    -- 调试UI
    if DEBUG_LOG_UIBUSY then
        local tsUI = display.newText({ text = "[ 0 ]", size = 24, font = Font.Bold })
            :align(display.CENTER, 0, 0)
            :addTo(self)

        local ts = gettime()

        tsUI:schedule(function()
            tsUI:setText(string.format("[ %.1f ]", gettime() - ts))
        end, 0.1)
    end
end

return BusyDialog

