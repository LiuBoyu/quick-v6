
----------------------------------------
-- 组件·HTTP代理 HttpProxy
----------------------------------------

return function(object, args)

    local component = { id = "HttpProxy" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local client = args.client or rl.G.HttpProxyClient
    local filter = args.filter or rl.G.HttpProxyFilter

    local reqs = {}

    local onBusy
    local onIdle

----------------------------------------
-- 组件参数
----------------------------------------

    function object:getHttpClient()
        return client
    end

    function object:isHttpBusy()
        for k, v in pairs(reqs) do
            return true
        end
        return false
    end

    function object:setHttpOnBusy(callback)
        onBusy = function()
            if object:isComponent("UI.Busy") then
                object:showBusy()
            end
            if callback then
                return callback()
            end
        end
    end

    function object:setHttpOnIdle(callback)
        onIdle = function()
            if object:isComponent("UI.Busy") then
                object:hideBusy()
            end
            if callback then
                return callback()
            end
        end
    end

    object:setHttpOnBusy()
    object:setHttpOnIdle()

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
    local send = function(method, endpoint, args)
        local args = args or {}
        local reqid

        local onComplete = args.onComplete

        args.onComplete = function(e)
            if not object.isObjectAlive then return end -- 判断对象是否存活
            reqs[reqid] = nil

            if not object:isHttpBusy() then
                onIdle()
            end

            -- 过滤器
            if filter then
                filter(e)
            end

            if onComplete then
                onComplete(e)
            end
        end

        if not object:isHttpBusy() then
            onBusy()
        end

        reqid = client[method](client, endpoint, args)
        reqs[reqid] = 1

        return reqid
    end

----------------------------------------
-- 对象方法·HTTP代理
----------------------------------------

    function object:DOWNLOAD(endpoint, args)
        return send("download", endpoint, args)
    end

    function object:GET(endpoint, args)
        return send("get", endpoint, args)
    end

    function object:POST(endpoint, args)
        return send("post", endpoint, args)
    end

    function object:PUT(endpoint, args)
        return send("put", endpoint, args)
    end

    function object:DELETE(endpoint, args)
        return send("delete", endpoint, args)
    end

    return component
end

