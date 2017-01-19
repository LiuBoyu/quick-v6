
----------------------------------------
-- 组件·事件分发 EventDispatcher (全局)
----------------------------------------

local id = 0

local function newHandleId()
    id = id + 1
    return id
end

----------------------------------------
-- 组件·事件分发 EventDispatcher (全局)
----------------------------------------

local getHandleOutput = function(handle)
    if handle.tag then
        if handle.ref then
            if handle.ref.isObjectAlive then
                return string.format("%s -> [%s:%s]", handle.ref:getObjectName(), handle.id, tostring(handle.listener))
            else
                if handle.ref.getObjectName then
                    return string.format("%s (销毁中) -> [%s:%s]", handle.ref:getObjectName(), handle.id, tostring(handle.listener))
                else
                    return string.format("%s (已销毁) -> [%s:%s]", handle.tag,                 handle.id, tostring(handle.listener))
                end
            end
        else
            return string.format("%s -> [%s:%s]", handle.tag, handle.id, tostring(handle.listener))
        end
    else
        return string.format("[%s:%s]", handle.id, tostring(handle.listener))
    end
end

----------------------------------------
-- 组件·事件分发 EventDispatcher
----------------------------------------

return function(object)

    local component = { id = "EventDispatcher" }

----------------------------------------
-- 组件参数
----------------------------------------

    local listeners = {}

----------------------------------------
-- 对象方法·管理事件
----------------------------------------

    -- 监听事件
    function object:addEventListener(name, listener, tag)
        local listenersByEvent = listeners[name]

        -- 初始化
        if not listenersByEvent then

            listenersByEvent = {}

            listeners[name] = listenersByEvent
        end

        -- object
        local ref

        if tag and string.sub(tag, 1, 4) == "OBJ:" then
            local objId = tonumber(string.sub(tag, 5))
            if objId then
                ref = rl.OBJECTS[objId]
            end
        end

        -- handle
        local handle = { id = newHandleId(), name = name, listener = listener, tag = tag, ref = ref }

        function handle:removeSelf()

            listenersByEvent[handle.id] = nil

            if DEBUG_LOG_EVENTLISTENER then
                object:logDEBUG("移除监听: %s -> %s", handle.name, getHandleOutput(handle))
            end
        end

        -- add listener
        listenersByEvent[handle.id] = handle

        if DEBUG_LOG_EVENTLISTENER then
            self:logDEBUG("添加监听: %s -> %s", handle.name, getHandleOutput(handle))
        end

        return handle
    end

    -- 分发事件
    function object:dispatchEvent(name, payload, logger)
        local listenersByEvent = listeners[name]

        if DEBUG_LOG_EVENTDISPATCHER then
            if payload then
                local output

                if logger then
                    output = logger(payload)
                else
                    output = payload
                end

                self:logDEBUG("事件: %s - %s", name, output)
            else
                self:logDEBUG("事件: %s", name)
            end
        end

        if not listenersByEvent then
            return
        end

        for _, v in pairs(listenersByEvent) do
            local cleanup = false

            if v.ref then
                if not v.ref.isObjectAlive then
                    cleanup = true
                end
            end

            if DEBUG_LOG_EVENTDISPATCHER then
                self:logDEBUG("事件:   -> %s", getHandleOutput(v))
            end

            if cleanup then
                -- cleanup
                v:removeSelf()
            else
                -- dispatch
                v.listener(payload)
            end
        end
    end

    -- 删除监听
    function object:removeEventListener(handle)
        handle:removeSelf()
    end

    return component
end

