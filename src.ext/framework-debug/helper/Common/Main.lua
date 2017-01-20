
return function()

    local sceneObject = G.Ctx:getSceneObject()
    local sceneName   = G.Ctx:getSceneName()

    ----------------
    -- Debug
    ----------------

    sceneObject:MENU("Debug")

    local baseline

    sceneObject:TEST("基准线", function()
        if baseline then
            baseline:removeSelf()
            baseline = nil
        else
            baseline = display.newNode()
                :addTo(G.Ctx:getSceneObject():getComponent("UI.Scene"):getEditor(), 200)

            local W = DESIGN_SCREEN_WIDTH
            local H = DESIGN_SCREEN_HEIGHT

            local min =  4/3
            local max = 16/9

            local w = (H * min)/2
            local h = (W / max)/2

            local a = display.newLine({ {display.cx - w, 0}, {display.cx - w, H} }, { borderColor = cc.c4f(1.0, 0.0, 0.0, 0.8), borderWidth = 2 })
                :addTo(baseline)
            local b = display.newLine({ {display.cx + w, 0}, {display.cx + w, H} }, { borderColor = cc.c4f(1.0, 0.0, 0.0, 0.8), borderWidth = 2 })
                :addTo(baseline)
            local c = display.newLine({ {0, display.cy - h}, {W, display.cy - h} }, { borderColor = cc.c4f(1.0, 0.0, 0.0, 0.8), borderWidth = 2 })
                :addTo(baseline)
            local d = display.newLine({ {0, display.cy + h}, {W, display.cy + h} }, { borderColor = cc.c4f(1.0, 0.0, 0.0, 0.8), borderWidth = 2 })
                :addTo(baseline)
        end
    end)

    local gridline

    sceneObject:TEST("网格线", function()
        if gridline then
            gridline:removeSelf()
            gridline = nil
        else
            gridline = display.newNode()
                :addTo(G.Ctx:getSceneObject():getComponent("UI.Scene"):getEditor(), 100)

            local c = cc.DrawNode:create()
                :addTo(gridline)

            local w, h = display.width, display.height
            local x, y = display.cx,    display.cy

            c:drawDot(cc.p(x,y), 5, cc.c4f(1,0,0,0.8))

            x = display.cx
            while x < display.right  do
                c:drawSegment(cc.p(x, 0), cc.p(x, h), 1, cc.c4f(1,0,0,0.2))
                x = x + 50
            end
            x = display.cx
            while x > display.left   do
                c:drawSegment(cc.p(x, 0), cc.p(x, h), 1, cc.c4f(1,0,0,0.2))
                x = x - 50
            end
            y = display.cy
            while y < display.top    do
                c:drawSegment(cc.p(0, y), cc.p(w, y), 1, cc.c4f(1,0,0,0.2))
                y = y + 50
            end
            y = display.cy
            while y > display.bottom do
                c:drawSegment(cc.p(0, y), cc.p(w, y), 1, cc.c4f(1,0,0,0.2))
                y = y - 50
            end
        end
    end)

    sceneObject:MENU("Debug", { newline = false })

    sceneObject:TEST("Config", function()
        log.info("Config: %s", G.Config)
    end)

    local systemUI

    sceneObject:TEST("System", function()
        if systemUI then
            systemUI:removeSelf()
            systemUI = nil
        else
            systemUI = G.Ctx:createSimpleModelUI(G.System, { ["Debug.*"] = "hide" })
                :align(display.CENTER, display.width * 1 / 4, display.top - 20)
                :scale(0.8)
                :addTo(G.Ctx:getSceneObject():getComponent("UI.Scene"):getEditor(), 100)
        end
    end)

    local meUI

    sceneObject:TEST("Me", function()
        if meUI then
            meUI:removeSelf()
            meUI = nil
        else
            meUI = G.Ctx:createSimpleModelUI(G.Me, { ["Debug.*"] = "hide" })
                :align(display.CENTER, display.width * 3 / 4, display.top - 20)
                :scale(0.8)
                :addTo(G.Ctx:getSceneObject():getComponent("UI.Scene"):getEditor(), 100)
        end
    end)

end

