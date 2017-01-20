
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor()
    UI:DebugScene(self)

    local ctUI = display.newText({ text = "0", size = 16, font = "Default"  })
            :align(display.LEFT_CENTER, 10+150*0, 10)
            :addTo(self)
    local lvUI = display.newText({ text = "0", size = 16, font = "Default"  })
            :align(display.LEFT_CENTER, 10+150*1, 10)
            :addTo(self)
    local xUI = display.newText({ text = "0", size = 16, font = "Default"  })
            :align(display.LEFT_CENTER, 10+150*0, 10+20*1)
            :addTo(self)
    local yUI = display.newText({ text = "0", size = 16, font = "Default"  })
            :align(display.LEFT_CENTER, 10+150*1, 10+20*1)
            :addTo(self)
    local vxUI = display.newText({ text = "0", size = 16, font = "Default"  })
            :align(display.LEFT_CENTER, 10+150*0, 10+20*2)
            :addTo(self)
    local vyUI = display.newText({ text = "0", size = 16, font = "Default"  })
            :align(display.LEFT_CENTER, 10+150*1, 10+20*2)
            :addTo(self)
    local axUI = display.newText({ text = "0", size = 16, font = "Default"  })
            :align(display.LEFT_CENTER, 10+150*0, 10+20*3)
            :addTo(self)
    local ayUI = display.newText({ text = "0", size = 16, font = "Default"  })
            :align(display.LEFT_CENTER, 10+150*1, 10+20*3)
            :addTo(self)

    local vx1UI = display.newText({ text = "vx+", size = 32, font = "Default"  })
            :align(display.LEFT_CENTER, display.cx-40, 30*2)
            :addTo(self)
    local vx2UI = display.newText({ text = "vx-", size = 32, font = "Default"  })
            :align(display.LEFT_CENTER, display.cx+40, 30*2)
            :addTo(self)
    local vy1UI = display.newText({ text = "vy+", size = 32, font = "Default"  })
            :align(display.LEFT_CENTER, display.cx-40, 30*1)
            :addTo(self)
    local vy2UI = display.newText({ text = "vy-", size = 32, font = "Default"  })
            :align(display.LEFT_CENTER, display.cx+40, 30*1)
            :addTo(self)

    UI:Button(vx1UI, { mode = "fast" })
    UI:Button(vx2UI, { mode = "fast" })
    UI:Button(vy1UI, { mode = "fast" })
    UI:Button(vy2UI, { mode = "fast" })

    local update
    local ct = 0
    local lv = 0

    local x, y, vx, vy, ax, ay = 0, 0, 0, 0, 0, 0

    vx1UI:setOnTap(function() vx = vx + 20 end)
    vx2UI:setOnTap(function() vx = vx - 20 end)
    vy1UI:setOnTap(function() vy = vy + 20 end)
    vy2UI:setOnTap(function() vy = vy - 20 end)

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        if update then
            ct = ct + dt
            lv = math.sqrt(vx*vx+vy*vy)
            ctUI:setString(ct)
            lvUI:setString(lv)
            xUI:setString(x)
            yUI:setString(y)
            vxUI:setString(vx)
            vyUI:setString(vy)
            axUI:setString(ax)
            ayUI:setString(ay)
            update(dt)
        end
    end)
    self:scheduleUpdate()

    --

    self:MENU("Util")

    self:TEST("直线", function(sandbox)
        local c = cc.DrawNode:create()
            :addTo(sandbox)

         x,  y = display.cx, display.cy
        vx, vy = math.sqrt(100*100/2), math.sqrt(100*100/2)

        update = function(dt)
            x = x + vx*dt
            y = y + vy*dt

            if x < 0 or display.width  < x
            or y < 0 or display.height < y then
                update = nil
                return
            end

            c:drawDot(cc.p(x,y), 2, cc.c4f(1,0,0,0.8))
        end
    end)

    self:TEST("圆形", function(sandbox)
        local c = cc.DrawNode:create()
            :addTo(sandbox)

         x,  y = display.cx, display.cy
        vx, vy = 0, 0

        update = function(dt)
            vx = 100*math.sin(math.rad(ct*100%360))
            vy = 100*math.cos(math.rad(ct*100%360))
             x =  x + vx*dt
             y =  y + vy*dt

            if x < 0 or display.width  < x
            or y < 0 or display.height < y then
                update = nil
                return
            end

            c:drawDot(cc.p(x,y), 2, cc.c4f(1,0,0,0.8))
        end
    end)

    self:TEST("贝塞尔二阶", function(sandbox)
        local c = cc.DrawNode:create()
            :addTo(sandbox)

         x,  y = display.cx, display.cy
        vx, vy = 0, 0

        update = function(dt)
            vx = 100*math.sin(math.rad(ct*100%360))
            vy = 100*math.cos(math.rad(ct*100%360))
             x =  x + vx*dt
             y =  y + vy*dt

            if x < 0 or display.width  < x
            or y < 0 or display.height < y then
                update = nil
                return
            end

            c:drawDot(cc.p(x,y), 2, cc.c4f(1,0,0,0.8))
        end
    end)

end

return M

