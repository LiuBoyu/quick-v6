
----------------------------------------
-- 组件·UI·对话框 Dialog
----------------------------------------

return function(object, args)

    local component = { id = "UI.Dialog" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local mode = args.mode or 1

    local effect = args.effect or "Center"  -- Center Left Right Up Down None
    local align  = args.align  or display.CENTER

    local width  = args.width  or 0
    local height = args.height or 0

    local bgcolor = args.bgcolor or { 0, 0, 0, 0 }

    if DEBUG_LOG_UIDIALOG then
        bgcolor = { 0, 255, 0, 63 }
    end

    local onTapBg = args.onTapBg
    local onClose = args.onClose

----------------------------------------
-- 组件参数
----------------------------------------

    local contained = function(obj, bg, p0)
        local s0 = bg:getContentSize()

        bg:setContentSize(cc.size(0,0))

        local ok = cc.rectContainsPoint(obj:getCascadeBoundingBox(), p0)

        bg:setContentSize(s0)

        return ok
    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    local a = display.ANCHOR_POINTS[align]

    local x0 = display.width  * a.x
    local y0 = display.height * a.y

    object:align(align, x0, y0)

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    function object:setOnTapBg(callback)
        onTapBg = callback
    end

    function object:setOnClose(callback)
        onClose = callback
    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    if mode == 1 then -- 屏蔽背景触控(非模态)

        local bg = display.newColorLayer(cc.c4b(unpack(bgcolor))):addTo(object, -1)

        -- 同步背景尺寸(对话框)
        bg:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function()
            bg:setContentSize(cc.size(0, 0))

            local rect = object:getCascadeBoundingBox()

            local p1, p2

            p1 = cc.p(rect.x, rect.y)
            p1 = object:convertToNodeSpace(p1)

            p2 = cc.p(rect.x + rect.width, rect.y + rect.height)
            p2 = object:convertToNodeSpace(p2)

            local x = p1.x
            local y = p1.y

            bg:setPosition(cc.p(x, y))

            local w = p2.x - p1.x
            local h = p2.y - p1.y

            bg:setContentSize(cc.size(w, h))
        end)
        bg:scheduleUpdate()

        -- 屏蔽背景触控
        bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(e)
        end)
        bg:setTouchEnabled( true )

    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    if mode == 2 then -- 屏蔽背景触控(模态)

        local bg = display.newColorLayer(cc.c4b(unpack(bgcolor))):addTo(object, -1)

        -- 同步背景尺寸(全屏幕)
        bg:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function()

            local p1 = object:convertToNodeSpace(cc.p(0,0))
            local p2 = object:convertToNodeSpace(cc.p(display.width,display.height))

            local x = p1.x
            local y = p1.y

            bg:setPosition(cc.p(x, y))

            local w = p2.x - p1.x
            local h = p2.y - p1.y

            bg:setContentSize(cc.size(w, h))
        end)
        bg:scheduleUpdate()

        -- 屏蔽背景触控
        bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(e)

            if     e.name == "began" then

                if contained(object, bg, { x = e.x, y = e.y }) then return end

                return true

            elseif e.name == "ended" then

                if contained(object, bg, { x = e.x, y = e.y }) then return end

                if onTapBg then
                    onTapBg()
                end

            end

        end)
        bg:setTouchEnabled( true )

    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    local playOnEnter = function(obj, callback)
        if mode == 0 then callback(); return end

        if    effect == "Center" then
            obj:scale(0)
            return transition.scaleTo(obj, {
                time       = 0.6,
                scale      = 1.0,
                easing     = { "ELASTICOUT", 1.0 },
                onComplete = function()
                    return callback()
                end,
            })
        elseif effect == "Left"   then
            callback(); return
        elseif effect == "Right"  then
            obj:placeTo(x0 + width/2, y0)
            return transition.moveTo(obj, {
                time       = 0.6,
                x          = x0 - width/2,
                y          = y0,
                easing     = { "ELASTICOUT", 1.0 },
                onComplete = function()
                    return callback()
                end,
            })
        elseif effect == "Up"     then
            callback(); return
        elseif effect == "Down"   then
            callback(); return
        else
            callback(); return
        end
    end

    local playOnExit  = function(obj, callback)
        if mode == 0 then callback(); return end

        if    effect == "Center" then
            return transition.scaleTo(obj, {
                time       = 0.2,
                scale      = 0,
                easing     = { "IN" },
                onComplete = function()
                    return callback()
                end,
            })
        elseif effect == "Left"   then
            callback(); return
        elseif effect == "Right"  then
            return transition.moveTo(obj, {
                time       = 0.2,
                x          = x0 + width/2,
                y          = y0,
                easing     = { "IN" },
                onComplete = function()
                    return callback()
                end,
            })
        elseif effect == "Up"     then
            callback(); return
        elseif effect == "Down"   then
            callback(); return
        else
            callback(); return
        end
    end

    -- status
    local status = 0 -- 开启
    local handle

    -- enter
    local enter = function()

        if DEBUG_LOG_UIDIALOG then
            object:logDEBUG("开启(对话框)")
        end

        handle = playOnEnter(object, function()
            status = 1 -- 正常
            handle = nil
        end)

    end

    -- exit
    local exit  = function(args)

        if status == 2 then
            return
        end

        if DEBUG_LOG_UIDIALOG then
            object:logDEBUG("关闭(对话框)")
        end

        if status == 0 then
            if handle then
                object:stopAction(handle)
                handle = nil
            end
        end

        status = 2 -- 关闭

        playOnExit(object, function()

            if onClose then
                onClose(args)
            end

            object:removeSelf()
        end)

    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    function object:close(args)
        exit(args)
    end

    enter()

    return component
end

