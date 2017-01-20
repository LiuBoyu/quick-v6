
local res = PROJNS .. "/scene/StartUp/"

local MainScene = class("MainScene", function()
    return display.newScene()
end)

function MainScene:ctor()
    UI:Scene(self)

    local a = display.newText({ text = "HelloWorld - " .. PROJID, size = 32, font = "Default" })
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)
    local b = display.newText({ text = os.date("%Y-%m-%d %H:%M:%S"), size = 32, font = "Default" })
        :align(display.CENTER, display.cx, display.cy - 50)
        :addTo(self)

    self:schedule(function()
        b:setText(os.date("%Y-%m-%d %H:%M:%S"))
    end, 0.1)
end

return MainScene

