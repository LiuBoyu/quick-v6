
----------------------------------------
-- 组件·数据模型 SimpleModel
----------------------------------------

return function(object, args)

    local component = { id = "SimpleModel" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("EventDispatcher") then object:addComponent("EventDispatcher") end

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local data      = args.data or {}
    local shortcuts = args.shortcuts

    local onInit
    local onSetting
    local onSet

----------------------------------------
-- 组件方法·默认
----------------------------------------

    function component:init(newdata)
        -- init data
        data = newdata or {}

        if onInit then
            onInit(data)
        end

        -- dispatch data event
        object:dispatchEvent("[@init]", data)
    end

    function component:dump()
        local t = {}
        for k, _ in pairs(data) do
            t[#t + 1] = k
        end
        table.sort(t)

        object:logDEBUG("# ")
        for _, k in ipairs(t) do
            object:logDEBUG("# %s: %s", k, data[k])
        end
        object:logDEBUG("# ")
    end

----------------------------------------
-- 组件方法·回调事件
----------------------------------------

    function component:setOnInit(callback)
        onInit = callback
    end

    function component:setOnSetting(callback)
        onSetting = callback
    end

    function component:setOnSet(callback)
        onSet = callback
    end

----------------------------------------
-- 对象方法·数据模型
----------------------------------------

    local logger = {}

    logger.set  = function(e) return e.v end
    logger.incr = function(e) return string.format("%s (+%s)" , tostring(e.v), tostring(e.V)) end
    logger.decr = function(e) return string.format("%s (-%s)" , tostring(e.v), tostring(e.V)) end
    logger.hset = function(e) return string.format("(%s = %s)", tostring(e.K), tostring(e.V)) end

----------------------------------------
-- 对象方法·数据模型
----------------------------------------

    function object:get(field)
        return data[field]
    end

    function object:set(field, value, opts)
        if type(value) == "function" then
            value = value( data[field] )
        end

        local event

        if opts and opts.event then
            event = opts.event
        else
            event = { k = field, v = value }
        end

        -- set value

        if onSetting then
            onSetting(field, value)
        end

        data[field] = value

        if onSet then
            onSet(event)
        end

        -- dispatch data event

        if opts and opts.forced then
            return
        end

        if opts and opts.logger then
            self:dispatchEvent(string.format("[%s]", field), event, opts.logger)
        else
            self:dispatchEvent(string.format("[%s]", field), event, logger.set)
        end
    end

    function object:getall()
        return data
    end

----------------------------------------
-- 对象方法·数据模型
----------------------------------------

    function object:incr(field, value)
        local v = data[field]

        if not v then
            v = 0
        end

        v = v + (value or 1)

        self:set(field, v, { event = { k = field, v = v, o = "incr", K = field, V = value or 1 }, logger = logger.incr })
    end

    function object:decr(field, value)
        local v = data[field]

        if not v then
            v = 0
        end

        v = v - (value or 1)

        self:set(field, v, { event = { k = field, v = v, o = "decr", K = field, V = value or 1 }, logger = logger.decr })
    end

----------------------------------------
-- 对象方法·数据模型
----------------------------------------

    function object:hget(k, field)
        local v = data[k]

        if not v then
            return
        end

        return v[field]
    end

    function object:hset(k, field, value)
        local v = data[k]

        if not v then
            v = {}
        end

        if type(value) == "function" then
            value = value( v[field] )
        end

        v[field] = value

        self:set(k, v, { event = { k = k, v = v, o = "hset", K = field, V = value }, logger = logger.hset })
    end

----------------------------------------
-- 对象方法·事件监听
----------------------------------------

    function object:addModelListener(field, listener, tag)
        return self:addEventListener(string.format("[%s]", field), listener, tag)
    end

----------------------------------------
-- 对象方法·快速访问
----------------------------------------

    if shortcuts then

        local mt = getmetatable(object) or {}
        local __index = mt.__index

        mt.__index = function(t, k)
            local K = shortcuts[k]

            if K then
                return data[K]
            end

            local v = rawget(t, k)

            if v then
                return v
            end

            if type(__index) == "function" then
                return __index(t, k)
            end

            if type(__index) == "table" then
                return __index[k]
            end

            return
        end

        mt.__newindex = function(t, k, v)
            local K = shortcuts[k]

            if K then

                t:set(k, v)

                return
            end

            rawset(t, k, v)
        end

        setmetatable(object, mt)

    end

    return component
end

