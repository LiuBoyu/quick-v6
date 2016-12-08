
----------------------------------------
-- 组件·UI·轮询 LongPoll
----------------------------------------

return function(object, args)

    local component = { id = "UI.LongPoll" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local onPoll
    local onBusy
    local onIdle

    local interval = 30

    local status = 0 -- 0 stop 1 start
    local isBusy = false
    local handle

----------------------------------------
-- 组件参数
----------------------------------------

    local isShowBusyUI = args.showBusyUI or false

    if isShowBusyUI then
        if not object:isComponent("UI.Busy") then object:addComponent("UI.Busy") end
    end

----------------------------------------
-- 对象方法·参数
----------------------------------------

    function object:getPollStatus()
        return status
    end

    function object:isPollBusy()
        return isBusy
    end

----------------------------------------
-- 对象方法·参数
----------------------------------------

    function object:setPollOnBusy(callback)
        onBusy = function()
            if isShowBusyUI then
                object:showBusyUI()
            end
            if callback then
                return callback()
            end
        end
    end

    function object:setPollOnIdle(callback)
        onIdle = function()
            if isShowBusyUI then
                object:hideBusyUI()
            end
            if callback then
                return callback()
            end
        end
    end

    function object:setPollInterval(v)
        if DEBUG_LOG_UILONGPOLL then
            self:logDEBUG("设置轮询: interval=%s", v)
        end
        interval = v
    end

----------------------------------------
-- 对象方法·参数
----------------------------------------

    function object:setOnPoll(callback, args)
        local args = args or {}

        onPoll = function(done)
            if callback then
                if DEBUG_LOG_UILONGPOLL then
                    self:logDEBUG("执行轮询: %s", os.date("%X", os.time()))
                end
                return callback(done)
            end
        end

        self:setPollOnBusy(args.onBusy)
        self:setPollOnIdle(args.onIdle)

        interval = args.interval or 30
    end

----------------------------------------
-- 对象方法·轮询
----------------------------------------

    local function poll()
        if isBusy then return end -- 状态 busy 忽略轮询
        -- 状态 idle >> busy
        isBusy = true
        onBusy()
        -- 执行任务
        onPoll(function()
            if not object.isObjectAlive then return end -- 判断对象是否存活
            -- 状态 busy >> idle
            isBusy = false
            onIdle()
            -- 状态 start 准备轮询
            if status == 1 then
                handle = object:performWithDelay(function()
                    handle = nil
                    -- 重新轮询
                    poll()
                end, interval)
            end
        end)
    end

    function object:forcePoll()
        if     status == 0 then -- 状态stop 强制执行任务
            -- 调试日志
            if DEBUG_LOG_UILONGPOLL then
                self:logDEBUG("强制轮询: status=0")
            end
            -- 强制轮询
            poll()
        elseif status == 1 then -- 状态wait 强制执行轮询
            -- 调试日志
            if DEBUG_LOG_UILONGPOLL then
                self:logDEBUG("强制轮询: status=1")
            end
            -- 停止轮询
            if handle then
                self:stopAction(handle)
                handle = nil
            end
            -- 重启轮询
            poll()
        end
    end

    function object:startPoll()
        if status == 0 then -- 判断是否 stop
            -- 调试日志
            if DEBUG_LOG_UILONGPOLL then
                self:logDEBUG("启动轮询: interval=%s", interval)
            end
            -- 状态 stop >> start
            status = 1
            -- 启动轮询
            poll()
        end
    end

    function object:stopPoll()
        if status == 1 then -- 判断是否 start
            -- 调试日志
            if DEBUG_LOG_UILONGPOLL then
                self:logDEBUG("停止轮询")
            end
            -- 状态 start >> stop
            status = 0
            -- 停止轮询
            if handle then
                self:stopAction(handle)
                handle = nil
            end
        end
    end

    return component
end

