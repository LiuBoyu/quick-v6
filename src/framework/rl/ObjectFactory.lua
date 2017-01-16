
local log = rl.log("ObjectFactory")

local searchCache = {}

----------------------------------------
-- 对象工厂(构造函数)
----------------------------------------

local ObjectFactory = rl.class("ObjectFactory")

function ObjectFactory:ctor()
    self.__searchPaths = {}
end

----------------------------------------
-- 搜索路径
----------------------------------------

function ObjectFactory:setSearchPaths(searchPaths)
    self.__searchPaths = searchPaths or {}

    if DEBUG_LOG_OBJECTFACTORY then
        log.debug("搜索路径: %s", self.__searchPaths);
    end
end

----------------------------------------
-- 搜索路径
----------------------------------------

function ObjectFactory:setPushedSearchPaths(searchPaths)
    if self.__searchPathsByPushed then
        self:backSearchPaths()
    end
    self:pushSearchPaths(searchPaths)
end

function ObjectFactory:pushSearchPaths(searchPaths)
    if self.__searchPathsByPushed then return end

    if searchPaths then

        for i = #searchPaths, 1, -1 do
            table.insert(self.__searchPaths, 1, searchPaths[i])
        end

        if DEBUG_LOG_OBJECTFACTORY then
            log.debug("搜索路径: %s", self.__searchPaths);
        end

        self.__searchPathsByPushed = searchPaths
    end
end

function ObjectFactory:backSearchPaths()
    if self.__searchPathsByPushed then

        for i, v in ipairs(self.__searchPathsByPushed) do
            table.remove(self.__searchPaths, 1)
        end

        if DEBUG_LOG_OBJECTFACTORY then
            log.debug("搜索路径: %s", self.__searchPaths);
        end

        self.__searchPathsByPushed = nil
    end
end

----------------------------------------
-- 对象工厂
----------------------------------------

function ObjectFactory:createClassInstance(name, ...)
    local cls = self:internalRequireBySearchPaths(name)
    local obj
    if     cls.__ctype == 1 then

        obj = cls.__create(...)
        for k, v in pairs(cls) do
            obj[k] = v
        end
        obj.class = cls

    elseif cls.__ctype == 2 then

        obj = setmetatable({}, cls)
        obj.class = cls

    end
    return obj
end

function ObjectFactory:createObject(name, ...)
    local cls = self:internalRequireBySearchPaths(name)
    local obj = cls.new(...)
    return obj
end

function ObjectFactory:require(name)
    local cls = self:internalRequireBySearchPaths(name)
    return cls
end

----------------------------------------
-- 加载脚本(内部函数)
----------------------------------------

function ObjectFactory:internalRequireBySearchPaths(name)
    for _, path in ipairs(self.__searchPaths) do

        local ok, cls = self:internalRequire(string.format("%s.%s", path, name))

        if ok then
            if DEBUG_LOG_OBJECTFACTORY then
                log.debug("加载脚本: %s.%s", path, name);
            end
            return cls
        end
    end
    if DEBUG_LOG_OBJECTFACTORY then
        log.debug("执行脚本: ... [%s] 没有找到: %s", name, self.__searchPaths)
    end
end

function ObjectFactory:internalRequire(fullname)
    local ok = searchCache[fullname]

    if not ok then
        local _ok, _ret = pcall(require, fullname)

        if     _ok then
            ok = 1
        else
            ok = 0
        end

        if not _ok then
            if not string.find(_ret, "module '.*' not found:") then
                return log.error("执行脚本: ... [%s] 加载异常: %s", fullname, _ret)
            end
        end

        searchCache[fullname] = ok
    end

    if ok == 1 then
        return true, require(fullname)
    end

    return false
end

return ObjectFactory

