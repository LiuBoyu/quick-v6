
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
        object:dispatchEvent("[@init]")
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

    function component:setOnSet(callback)
        onSet = callback
    end

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

        -- set value
        data[field] = value

        if opts and opts.forced then
            return
        end

        if onSet then
            onSet(field, value)
        end

        -- dispatch data event
        self:dispatchEvent(string.format("[%s]", field), { k = field, v = value })
    end

    function object:getall()
        return data
    end

    function object:setall(newdata)
        component:init(newdata)
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

        self:set(k, v)
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

