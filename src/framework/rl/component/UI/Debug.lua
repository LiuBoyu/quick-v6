
----------------------------------------
-- 组件·UI·调试 Debug
----------------------------------------

return function(object, args)

    local component = { id = "UI.Debug" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local enabled = false
    local dragged = false

    local s = 10

    local c = cc.c4f(1,0,0,0.6)
    local r = 0.6

----------------------------------------
-- 组件参数
----------------------------------------

    local editor = rl.G.Ctx:getSceneObject():getComponent("UI.Scene"):getEditor()

    local target = cc.DrawNode:create():addTo(editor)

    target:setContentSize(s*2, s*2)

    target:drawCircle(cc.p(s,s), s, 0, 16, false, 1, 1, c)
    target:drawDot(cc.p(s,s), r*5, c)

    local draw = cc.DrawNode:create():addTo(editor)
    local text = display.newTTFLabel({ text = "", size = 16, color = cc.c3b(255,0,0) }):addTo(editor)
    local xxyy = display.newTTFLabel({ text = "", size = 16, color = cc.c3b(255,0,0) }):addTo(editor)

    object:addNodeEventListener(cc.NODE_EVENT, function(e)
        if e.name == "cleanup" then

            draw:removeSelf()
            text:removeSelf()
            xxyy:removeSelf()

            target:removeSelf()

        end
    end)

----------------------------------------
-- 对象方法·调试
----------------------------------------

    object:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function()
        local rect = object:getCascadeBoundingBox()

        local x, y = rect.x,     rect.y
        local w, h = rect.width, rect.height

        local p = object:getParent():convertToWorldSpace(cc.p(object:getPositionX(), object:getPositionY()))

        target:pos(p.x - s, p.y - s)

        draw:clear()
        text:setString("")

        if enabled then

            draw:drawSegment(cc.p(x      ,y+h*1/3), cc.p(x+w    ,y+h*1/3), r, c)
            draw:drawSegment(cc.p(x      ,y+h*2/3), cc.p(x+w    ,y+h*2/3), r, c)
            draw:drawSegment(cc.p(x+w*1/3,y      ), cc.p(x+w*1/3,y+h    ), r, c)
            draw:drawSegment(cc.p(x+w*2/3,y      ), cc.p(x+w*2/3,y+h    ), r, c)

            draw:drawSegment(cc.p(x      ,y      ), cc.p(x      ,y+h    ), r, c)
            draw:drawSegment(cc.p(x      ,y      ), cc.p(x+w    ,y      ), r, c)
            draw:drawSegment(cc.p(x+w    ,y+h    ), cc.p(x      ,y+h    ), r, c)
            draw:drawSegment(cc.p(x+w    ,y+h    ), cc.p(x+w    ,y      ), r, c)

            if dragged then

                draw:drawSegment(cc.p(0,     y+h/2), cc.p(display.width, y+h/2         ), r, c)
                draw:drawSegment(cc.p(x+w/2, 0    ), cc.p(x+w/2,         display.height), r, c)

            end

            if x+w/2 > display.cx then
                text:setPositionX(x   - 15)
            else
                text:setPositionX(x+w + 15)
            end

            if y+h/2 > display.cy then
                text:setPositionY(y   - 15)
            else
                text:setPositionY(y+h + 15)
            end

            text:setString(string.format("%d,%d", object:getPosition()))

            if x+w/2 > display.cx then
                xxyy:setPositionX(x   - 15)
            else
                xxyy:setPositionX(x+w + 15)
            end

            if y+h/2 > display.cy then
                xxyy:setPositionY(y   - 45)
            else
                xxyy:setPositionY(y+h + 45)
            end

        end
    end)
    object:scheduleUpdate()

----------------------------------------
-- 对象方法·拖拽
----------------------------------------

    local onDrag = function()

        text:setSystemFontSize(24)
        xxyy:setSystemFontSize(24)

        dragged = true
    end

    local onDrop = function()

        text:setSystemFontSize(16)
        xxyy:setSystemFontSize(16)

        dragged = false
    end

    local pos_s, pos_o, pos_d

    local checkOnDrag = function(e, contained)
        if     e.name == "began" then

            pos_s = cc.p( object:getPosition() )
            pos_d = cc.p( 0,0 )
            pos_o = cc.pSub( pos_s, cc.p(e.x, e.y) )

            onDrag()

        elseif e.name == "moved" then

            object:setPosition(cc.pAdd( cc.p(e.x, e.y), pos_o ))

            pos_d = cc.pSub( cc.p( object:getPosition() ), pos_s )

            xxyy:setString(string.format("( %d,%d )", pos_d.x, pos_d.y ))

        elseif e.name == "ended" then

            onDrop()

        end
    end

----------------------------------------
-- 对象方法·点击&长按
----------------------------------------

    local onTap     = function()

        enabled = true

    end

    local onTapHold = function()

        enabled = false

    end

    local tap     = { status = "ready" }
    local taphold = { status = "ready" }

    local checkOnTap = function(e, contained)
        if     e.name == "began" then

            tap.status = "ready"

        elseif e.name == "ended" then

            if tap.status ~= "ready" or not contained then return end

            tap.status = "done"
            onTap()

        end
    end

    local checkOnTapHold = function(e)
        if     e.name == "began" then

            taphold.status = "ready"
            taphold.handle = target:performWithDelay(function()

                taphold.status = "done"
                taphold.handle = nil

                tap.status = "ignored"

                onTapHold()
            end, 1.0)

        else

            taphold.status = "ignored"

            if taphold.handle then
                target:stopAction(taphold.handle)
            end

            taphold.handle = nil

        end
    end

----------------------------------------
-- 对象方法·触控
----------------------------------------

    target:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(e)

        local contained = cc.rectContainsPoint(target:getCascadeBoundingBox(), { x = e.x, y = e.y })

        checkOnTap    (e, contained)
        checkOnTapHold(e, contained)

        if enabled or dragged then
            checkOnDrag(e, contained)
        end

        if e.name == "began" then
            return true
        end

    end)
    target:setTouchEnabled( true )

    return component
end

