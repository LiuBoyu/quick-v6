
----------------------------------------
-- 组件·UI·拖拽 DragDrop
----------------------------------------

return function(object, args)

    local component = { id = "UI.DragDrop" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("UI.Button") then object:addComponent("UI.Button") end

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local onDrag = args.onDrag
    local onDrop = args.onDrop

    local checkOnDrag = args.checkOnDrag
    local checkOnDrop = args.checkOnDrop

    local enabled = true

    local drag = { status = "ready" }

    if not onDrag then
        onDrag = function(e)
            local dx = e.x - e.prevX
            local dy = e.y - e.prevY

            local srcPt = cc.p( object:getPosition() )
            local dstPt = cc.p( srcPt.x + dx, srcPt.y + dy )

            object:setPosition(dstPt)
        end
    end

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    local checkNodeOnDrag = function(e)
        if     e.name == "began" then

            drag.status = "ready"
            drag.x = e.x
            drag.y = e.y

        elseif e.name == "moved" then

            if drag.status == "ready" then

                if math.abs(e.x - drag.x) > (display.width  / 100)
                or math.abs(e.y - drag.y) > (display.height / 100) then

                    if DEBUG_LOG_UIBUTTON then
                        object:logDEBUG("拖拽")
                    end

                    drag.status = "drag"
                end

            end

            if drag.status == "drag" then
                if onDrag then
                    onDrag(e)
                end
            end

        else

            if drag.status == "drag" then

                if DEBUG_LOG_UIBUTTON then
                    object:logDEBUG("落下")
                end

                if onDrop then
                    onDrop(e)
                end
            end

        end
    end

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    object:setOnTapDrag(function(e, contained)

        if enabled and onDrag then
            checkNodeOnDrag(e, contained)
        end

    end)

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    function object:setDragDropEnabled(v)
        enabled = v
    end

----------------------------------------
-- 对象方法·按钮
----------------------------------------

    function object:setOnDrag(callback)
        onDrag = callback
    end

    function object:setOnDrop(callback)
        onDrop = callback
    end

    function object:setCheckOnDrag(callback)
        checkOnDrag = callback
    end

    function object:setCheckOnDrop(callback)
        checkOnDrop = callback
    end

    return component
end

