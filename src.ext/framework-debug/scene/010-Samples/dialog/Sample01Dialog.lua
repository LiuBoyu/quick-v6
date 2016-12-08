
local res = "framework-debug/scene/010-Samples/"

local Img = {
    Background  = res .. "card1.png",
    Option      = res .. "option.png",
}

local Dialog = class("Sample01Dialog", function()
    return display.newNode()
end)

function Dialog:ctor( args )
    UI:Dialog(self, { mode = args.mode, bgcolor = {0,0,0,127} })

    local a = display.newSprite(Img.Background)
        :align(display.CENTER, 0, 0)
        :addTo(self)

    local b = display.newSprite(Img.Option)
        :align(display.CENTER, 80, 125)
        :addTo(self)
    UI:Button(b)

    b:setOnTap(function()
        self:close()
    end)
end

return Dialog

