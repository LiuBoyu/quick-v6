
local res = "framework-debug/scene/QuickV6/"

local Img = {
    Close   = res .. "close.png",
    Bg      = res .. "card.png",
}

local Dialog = class("HelloDialog", function()
    return display.newNode()
end)

function Dialog:ctor( args )
    UI:Dialog(self, { mode = args.mode, bgcolor = {0,0,0,127} })

    local a = display.newSprite(Img.Bg)
        :align(display.CENTER, 0, 0)
        :addTo(self)

    local b = display.newSprite(Img.Close)
        :align(display.CENTER, 80, 125)
        :addTo(self)
    UI:Button(b)

    b:setOnTap(function()
        self:close()
    end)
end

return Dialog

