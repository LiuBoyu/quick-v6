
----------------------------------------
-- 组件 Component (全局)
----------------------------------------

rl.COMPONENT = function(name, component)

    if type(component) == "string" then
        component = require(component)
    end

    rl.COMPONENTS[name] = component
end

----------------------------------------
-- 组件 Component (全局)
----------------------------------------

local id = 0

local function newObjId()
    id = id + 1
    return id
end

----------------------------------------
-- 组件 Component
----------------------------------------

return function(object, args)

----------------------------------------
-- 组件参数
----------------------------------------

    local object = object or {}
    local args   = args   or {}

----------------------------------------
-- 对象方法·对象标识
----------------------------------------

    local objClass = args.class or object.__cname or "Object"

    local objId   = newObjId()
    local objName = string.format("%s(%s)", objClass, objId)

    function object:getObjectId()
        return objId
    end

    function object:getObjectName()
        return objName
    end

----------------------------------------
-- 对象方法·对象日志
----------------------------------------

    local log = rl.log(objName)

    function object:logDEBUG( ... )
        log.debug( ... )
    end

    function object:logINFO( ... )
        log.info( ... )
    end

    function object:logWARN( ... )
        log.warn( ... )
    end

    function object:logERROR( ... )
        log.error( ... )
    end

----------------------------------------
-- 对象方法·检查组件
----------------------------------------

    local components = {}

    function object:isComponent(name)
        if components[name] then
            return true
        end
    end

----------------------------------------
-- 对象方法·管理组件
----------------------------------------

    -- 获取所有组件
    function object:getAllComponents()
        return components
    end

    -- 获取组件
    function object:getComponent(name)
        return components[name]
    end

    -- 添加组件
    function object:addComponent(name, args)
        local component = rl.COMPONENTS[name]

        if components[name] then
            log.warn("添加组件[%s] .. 忽略", name)
            return self
        end

        if not component then
            if string.sub(name, 1, 1) ~= "." then

                local ok, ret = pcall(require, name)
                if ok then
                    component = ret
                else
                    log.error("添加组件[%s] .. 失败: %s", name, ret)
                end

            else

                local     ret = rl.G.Ctx:require(string.sub(name, 2))
                if ret then
                    component = ret
                else
                    log.error("添加组件[%s] .. 失败", name)
                end

            end
        end

        if not component then
            return self
        end

        components[name] = component(self, args)

        if DEBUG_LOG_COMPONENT then
            log.debug("添加组件[%s]", name)
        end

        return self
    end

----------------------------------------
-- 生命周期
----------------------------------------

    if DEBUG_LOG_COMPONENT then
        object:logDEBUG("创建实体")
    end

    object.isObjectAlive = true

    rl.OBJECTS[objId] = object

    if object.addNodeEventListener then
        object:addNodeEventListener(cc.NODE_EVENT, function(e)
            if e.name == "cleanup" then

                if DEBUG_LOG_COMPONENT then
                    object:logDEBUG("销毁实体")
                end

                object.isObjectAlive = nil

                rl.OBJECTS[objId] = nil

            end
        end)
    else
            function object:removeSelf()

                if DEBUG_LOG_COMPONENT then
                    object:logDEBUG("销毁实体")
                end

                object.isObjectAlive = nil

                rl.OBJECTS[objId] = nil

            end
    end

    return object
end

