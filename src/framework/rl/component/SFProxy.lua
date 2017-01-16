
----------------------------------------
-- 组件·SFClient代理 SFProxy
----------------------------------------

return function(object, args)

    local component = { id = "SFProxy" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("EventProxy") then object:addComponent("EventProxy") end

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local client = args.client or rl.G.SFProxyClient
    local filter = args.filter or rl.G.SFProxyFilter
    local source = args.source or rl.G.Net

    local req = {}

    local onBusy
    local onIdle

----------------------------------------
-- 组件参数
----------------------------------------

    function object:getSFClient()
        return client
    end

    function object:isSFBusy()
        for k, v in pairs(req) do
            return true
        end
        return false
    end

    function object:setSFOnBusy(callback)
        onBusy = function()
            if object:isComponent("UI.Busy") then
                object:showBusy()
            end
            if callback then
                return callback()
            end
        end
    end

    function object:setSFOnIdle(callback)
        onIdle = function()
            if object:isComponent("UI.Busy") then
                object:hideBusy()
            end
            if callback then
                return callback()
            end
        end
    end

    object:setSFOnBusy()
    object:setSFOnIdle()

----------------------------------------
-- 组件参数
----------------------------------------

    -- 清理请求(生命周期)
    if object.addNodeEventListener then
        object:addNodeEventListener(cc.NODE_EVENT, function(e)
            if e.name == "cleanup" then

                for k, v in pairs(req) do
                    client:cancel(k)
                end

            end
        end)
    end

----------------------------------------
-- 组件参数
----------------------------------------

    -- 发送请求
    local request = function(endpoint, args)
        local args = args or {}
        local id

        local onComplete = args.onComplete

        args.onComplete = function(e)
            if not object.isObjectAlive then return end -- 判断对象是否存活
            if id then
                req[id] = nil
            end

            if not object:isSFBusy() then
                onIdle()
            end

            filter(e)

            if onComplete then
                onComplete(e)
            end
        end

        if not object:isSFBusy() then
            onBusy()
        end

        id = client:request(endpoint, args)

        if id then
            req[id] = 1
        end

        return id
    end

----------------------------------------
-- 组件参数
----------------------------------------

    -- 接收消息
    local receive = function(cmd, args)
        local args = args or {}

        local handle, timeout

        handle = object:listenEvent(args.source or source, cmd, function(payload)
            if timeout then
                object:stopAction(timeout)
            end

            handle:removeSelf()

            if args.callback then
                args.callback({ cmd = cmd, payload = payload, status = 200 })
            end
        end)

        if args.timeout then
            timeout = object:performWithDelay(function()

                handle:removeSelf()

                if args.callback then
                    args.callback({ cmd = cmd, status = -1 })
                end
            end, args.timeout)
        end

        return handle
    end

----------------------------------------
-- 对象方法·SFClient代理
----------------------------------------

    function object:REQUEST(endpoint, args)
        return request(endpoint, args)
    end

    function object:PUBLISH(endpoint, args)
        return client:publish(endpoint, args)
    end

    function object:RECEIVE(endpoint, args)
        return receive(endpoint, args)
    end

    return component
end

