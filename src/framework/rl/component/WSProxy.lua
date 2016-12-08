
----------------------------------------
-- 组件·WebSocket代理 WSProxy
----------------------------------------

return function(object, args)

    local component = { id = "WSProxy" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local client = args.client or rl.G.WSProxyWSClient
    local filter = args.filter or rl.G.WSProxyWSFilter

    local reqs = {}

    local onBusy
    local onIdle

----------------------------------------
-- 组件参数
----------------------------------------

    function object:getWSClient()
        return client
    end

    function object:isWSBusy()
        for k, v in pairs(reqs) do
            return true
        end
        return false
    end

    function object:setWSOnBusy(callback)
        onBusy = function()
            if object:isComponent("UI.Busy") then
                object:showBusyUI()
            end
            if callback then
                return callback()
            end
        end
    end

    function object:setWSOnIdle(callback)
        onIdle = function()
            if object:isComponent("UI.Busy") then
                object:hideBusyUI()
            end
            if callback then
                return callback()
            end
        end
    end

    object:setWSOnBusy()
    object:setWSOnIdle()

----------------------------------------
-- 组件参数
----------------------------------------

    -- 清理请求(生命周期)
    if object.addNodeEventListener then
        object:addNodeEventListener(cc.NODE_EVENT, function(e)
            if e.name == "cleanup" then

                for k, v in pairs(reqs) do
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
        local reqid

        local onComplete = args.onComplete

        args.onComplete = function(cmd, msg)
            if not object.isObjectAlive then return end -- 判断对象是否存活
            if reqid then
                reqs[reqid] = nil
            end

            if not object:isWSBusy() then
                onIdle()
            end

            local e = { cmd = cmd, msg = msg }

            if type(msg) == "table" then
                e.status = msg.errcode and msg.errcode or 200
            else
                e.status = 200
            end

            -- 过滤器
            filter(e)

            if onComplete then
                onComplete(e)
            end
        end

        if not object:isWSBusy() then
            onBusy()
        end

        if args.onlyonce then
            reqid = client:requestOnlyOnce(endpoint, args)
        else
            reqid = client:request(endpoint, args)
        end

        if reqid then
            reqs[reqid] = 1
        end

        return reqid
    end

----------------------------------------
-- 对象方法·WebSocket代理
----------------------------------------

    function object:PUBLISH(endpoint, args)
        return client:publish(endpoint, args)
    end

    function object:REQUEST(endpoint, args)
        return request(endpoint, args)
    end

    return component
end

