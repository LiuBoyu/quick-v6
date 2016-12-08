
----------------------------------------
-- 组件·事件代理 EventProxy
----------------------------------------

return function(object)

    local component = { id = "EventProxy" }

----------------------------------------
-- 组件参数
----------------------------------------

    local handles = {}

    -- 清理监听(生命周期)
    if object.addNodeEventListener then
        object:addNodeEventListener(cc.NODE_EVENT, function(e)
            if e.name == "cleanup" then

                for _, v in ipairs(handles) do
                    v:removeSelf()
                end

            end
        end)
    end

    -- 监听事件
    local listenEvent = function(src, name, listener, tag)
        local handle = src:addEventListener(name, listener, tag)

        handles[#handles+1] = handle

        return handle
    end

    -- 监听模型
    local listenModel = function(src, name, listener, tag)
        local handle = src:addModelListener(name, listener, tag)

        handles[#handles+1] = handle

        return handle
    end

----------------------------------------
-- 对象方法·事件代理
----------------------------------------

    function object:listenEvent(src, name, listener)
        if not self.isObjectAlive then return end

        return listenEvent(src, name, listener, string.format("OBJ:%s", self:getObjectId()))
    end

    function object:listenModel(src, name, listener)
        if not self.isObjectAlive then return end

        return listenModel(src, name, listener, string.format("OBJ:%s", self:getObjectId()))
    end

    function object:listenModelByInit(src, name, listener)
        if not self.isObjectAlive then return end

        if listener then
            listener({ k = name, v = src:get(name), init = true })
        end

        return listenModel(src, name, listener, string.format("OBJ:%s", self:getObjectId()))
    end

    return component
end

