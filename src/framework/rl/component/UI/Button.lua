
----------------------------------------
-- 组件·UI·按钮 Button
----------------------------------------

return function(object, args)

    local component = { id = "UI.Button" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local onPress   = args.onPress   or function()
        object:setScaleX(object:getScaleX() * 0.96)
        object:setScaleY(object:getScaleY() * 0.96)
    end

    local onRelease = args.onRelease or function()
        object:setScaleX(object:getScaleX() / 0.96)
        object:setScaleY(object:getScaleY() / 0.96)
    end

    local onTap     = args.onTap
    local onTapHold = args.onTapHold

    local checkOnTap     = args.checkOnTap
    local checkOnTapHold = args.checkOnTapHold

    local mode = args.mode or "slow"

    local enabled = true

    local status = "ready"
    local ts0

    local tap     = { status = "ready" }
    local taphold = { status = "ready" }

    local checkTs

    if mode == "slow" then

        checkTs = function()
            local ts1 = gettime()

            if not ts0 then
                ts0 = ts1 - 60
            end

            if (ts1 - ts0) > 1.0 then
                ts0 = ts1
                return true
            else
                ts0 = ts1
                return false
            end
        end

    end

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    local checkNodeOnTouch = function(e, contained)

        if     e.name == "began" then

            status = "done"
            onPress()

        elseif e.name == "moved" then


            if status == "ready" and     contained then

                status = "done"
                onPress()

            end

            if status == "done"  and not contained then

                status = "ready"
                onRelease()

            end

        else
            if status == "done" then

                status = "ready"
                onRelease()

            end
        end
    end

    local checkNodeOnTap = function(e, contained)
        if     e.name == "began" then

            tap.status = "ready"
            tap.x = e.x
            tap.y = e.y

        elseif e.name == "ended" then

            if tap.status ~= "ready" or not contained then return end

            tap.status = "done"

            if (checkOnTap and not checkOnTap()) or (checkTs and not checkTs()) then

                if DEBUG_LOG_UIBUTTON then
                    object:logDEBUG("点击(false)")
                end

            else

                if DEBUG_LOG_UIBUTTON then
                    object:logDEBUG("点击")
                end

                onTap()
            end

        else

            if math.abs(e.x - tap.x) > (display.width  * 2 / 100)
            or math.abs(e.y - tap.y) > (display.height * 2 / 100) then
                tap.status = "ignored"
            end

        end
    end

    local checkNodeOnTapHold = function(e)
        if     e.name == "began" then

            taphold.status = "ready"
            taphold.handle = object:performWithDelay(function()

                taphold.status = "done"
                taphold.handle = nil

                tap.status = "ignored"

                if checkOnTapHold and not checkOnTapHold() then

                    if DEBUG_LOG_UIBUTTON then
                        object:logDEBUG("长按(false)")
                    end

                else

                    if DEBUG_LOG_UIBUTTON then
                        object:logDEBUG("长按")
                    end

                    onTapHold()
                end
            end, 1.0)

        else

            taphold.status = "ignored"

            if taphold.handle then
                object:stopAction(taphold.handle)
            end

            taphold.handle = nil

        end
    end

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    object:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(e)

        local contained = cc.rectContainsPoint(object:getCascadeBoundingBox(), { x = e.x, y = e.y })

        if onPress or onRelease then
            checkNodeOnTouch(e, contained)
        end

        if enabled and onTap then
            checkNodeOnTap(e, contained)
        end

        if enabled and onTapHold then
            checkNodeOnTapHold(e, contained)
        end

        if e.name == "began" then
            return true
        end

    end)

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    function object:setButtonEnabled(v)
        enabled = v
    end

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    function object:setOnPress(callback)
        onPress = callback
    end

    function object:setOnRelease(callback)
        onRelease = callback
    end

    function object:setOnTap(callback)
        onTap = callback
    end

    function object:setOnTapOnce(callback)
        if callback then

            onTap = function()

                callback()

                enabled = false
            end

        else
            onTap = callback
        end
    end

    function object:setOnTapHold(callback)
        onTapHold = callback
    end

    function object:setCheckOnTap(callback)
        checkOnTap = callback
    end

    function object:setCheckOnTapHold(callback)
        checkOnTapHold = callback
    end

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    function object:tap()
        if enabled and onTap then
            if checkOnTap and not checkOnTap() then

                if DEBUG_LOG_UIBUTTON then
                    object:logDEBUG("点击(false)")
                end

            else

                if DEBUG_LOG_UIBUTTON then
                    object:logDEBUG("点击")
                end

                onTap()
            end
        end
    end

    function object:taphold()
        if enabled and onTapHold then
            if checkOnTapHold and not checkOnTapHold() then

                if DEBUG_LOG_UIBUTTON then
                    object:logDEBUG("长按(false)")
                end

            else

                if DEBUG_LOG_UIBUTTON then
                    object:logDEBUG("长按")
                end

                onTapHold()
            end
        end
    end

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    object:setTouchEnabled(true)

    return component
end

