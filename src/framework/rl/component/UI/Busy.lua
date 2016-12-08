
----------------------------------------
-- 组件·UI·等待 Busy
----------------------------------------

return function(object, args)

    local component = { id = "UI.Busy" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local mode = args.mode or 2

    local onBusy = args.onBusy
    local onIdle = args.onIdle

    local ct = 0

    local busy
    local wait

----------------------------------------
-- 组件参数
----------------------------------------

    if mode > 0 then

        busy = display.newNode():addTo(object, 9999)

        -- 同步节点尺寸
        busy:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function()
            busy:setContentSize(cc.size(0, 0))

            local rect = object:getCascadeBoundingBox()

            local p1, p2

            p1 = cc.p(rect.x, rect.y)
            p1 = object:convertToNodeSpace(p1)

            p2 = cc.p(rect.x + rect.width, rect.y + rect.height)
            p2 = object:convertToNodeSpace(p2)

            local x = p1.x
            local y = p1.y

            busy:setPosition(cc.p(x, y))

            local w = p2.x - p1.x
            local h = p2.y - p1.y

            busy:setContentSize(cc.size(w, h))
        end)
        busy:scheduleUpdate()

        -- 屏蔽节点触控
        busy:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(e)
        end)
        busy:setTouchEnabled( true )

        -- 隐藏等待
        busy:hide()

    end

----------------------------------------
-- 对象方法·等待
----------------------------------------

    function object:setOnBusy(callback)
        onBusy = callback
    end

    function object:setOnIdle(callback)
        onIdle = callback
    end

----------------------------------------
-- 对象方法·等待
----------------------------------------

    function object:isBusy()
        if ct > 0 then
            return true
        end
        return false
    end

----------------------------------------
-- 对象方法·等待
----------------------------------------

    function object:performWithBusy(callback)

        self:showBusy()

        callback(function()

            if not self.isComponent then -- 判断节点是否存活
                return
            end

            self:hideBusy()
        end)
    end

    function object:showBusyUI()

        if ct == 0 then

            if mode > 0 and     busy then
                busy:show()
            end

            if mode > 1 and not wait then
                local rect = object:getCascadeBoundingBox()

                local p0 = object:convertToNodeSpace( cc.p(rect.x + rect.width/2, rect.y + rect.height/2) )
                local s0 = math.min(rect.width, rect.height) / 240

                if s0 > 1 then s0 = 1 end

                local ok, ret = pcall(function()
                    return rl.G.Ctx:createUI("BusyUI")
                end)

                if ok then
                    wait = ret
                else
                    wait = display.newText({ text = "[ ]", size = 32 })
                    wait:schedule(function()
                        wait.ts = (wait.ts or 0) + 1
                        wait:setText("[ " .. string.rep(".", wait.ts) .. " ]")
                    end, 0.5)
                end

                wait:addTo(object, 9999)
                wait:align(display.CENTER, p0.x, p0.y)
                wait:scale(s0)
            end

            if onBusy then
                onBusy()
            end

        end

        ct = ct + 1
    end
    object.showBusy = object.showBusyUI

    function object:hideBusyUI()
        ct = ct - 1

        if ct == 0 then

            if onIdle then
                onIdle()
            end

            if wait then
                wait:removeSelf()
                wait = nil
            end

            if busy then
                busy:hide()
            end

        end

    end
    object.hideBusy = object.hideBusyUI

    return component
end

