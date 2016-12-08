
local log = rl.log("Cache")

local lfs = require("lfs")

local Cache = rl.class("Cache")

function Cache:ctor(args)
    -- 构建参数
    self.storagePath = (args or {}).storagePath or PROJ_DOC_PATH .. "caches/"
    self.storageType = (args or {}).storageType or "file"                       -- "memory", "sqlite"
    self.contentType = (args or {}).contentType or "?"                          -- "application/json"
    self.context     = (args or {}).context     or "?"
    self.expires     = (args or {}).expires     or 60 * 60 * 24 * 30

    -- 构建参数
    self.storage     = {}

    -- 构建目录
    os.mkdir(self.storagePath)
end

----------------------------------------
-- 基本操作 (查找、读取、写入)
----------------------------------------

function Cache:find(k)
    local data, size, time = self:internalFind(k)

    if not data then
        return
    end

    if self:internalExpired(time) then
        return
    end

    local v = { contentType = self.contentType }

    v.data = data
    v.size = size

    return v
end

function Cache:read(k)
    local data, size, time = self:internalRead(k)

    if not data then
        return
    end

    if self:internalExpired(time) then
        return
    end

    local v = { contentType = self.contentType }

    v.data     = data
    v.size     = size
    v.ts       = time

    v.res      = self:internalDecode(data)

    if not v.res then
        return
    end

    return v
end

function Cache:save(k, v)
    self:internalSave(k, v)
end

----------------------------------------
-- 查找缓存 (内部)
----------------------------------------

function Cache:internalFind(k)
    local k = self:internalGetKey(k, self.context)

    if     self.storageType == "file"   then

        local v = self.storagePath .. k

        if os.exists(v) then
            return k, lfs.attributes(v, "size"), lfs.attributes(v, "modification")
        end

    elseif self.storageType == "memory" then

        local v = self.storage[k]

        if v then
            return k, string.len(v[1]), v[2]
        end

    elseif self.storageType == "sqlite" then
        -- TODO
    end
end

----------------------------------------
-- 读取缓存 (内部)
----------------------------------------

function Cache:internalRead(k)
    local k = self:internalGetKey(k, self.context)

    if     self.storageType == "file"   then

        local k = self.storagePath .. k

        if not os.exists(k) then
            return
        end

        local v = os.read(k)

        if v then
            return v, string.len(v), lfs.attributes(k, "modification")
        end

    elseif self.storageType == "memory" then

        local v = self.storage[k]

        if v then
            return v[1], string.len(v[1]), v[2]
        end

    elseif self.storageType == "sqlite" then
        -- TODO
    end
end

----------------------------------------
-- 写入缓存 (内部)
----------------------------------------

function Cache:internalSave(k, v)
    local k = self:internalGetKey(k, self.context)

    if     self.storageType == "file"   then

        local k = self.storagePath .. k
        local v = self:internalEncode(v)

        if v then
            os.safewrite(k, v)
        end

    elseif self.storageType == "memory" then

        local v = self:internalEncode(v)

        if v then
            self.storage[k] = { v, os.time() }
        end

    elseif self.storageType == "sqlite" then
        -- TODO
    end
end

----------------------------------------
-- 编码解码 (基于ContentType)
----------------------------------------

function Cache:internalEncode(v)
    if     self.contentType == "application/json" then
        return json.encode(v)

    elseif self.contentType == "?"                then
        if type(v) ~= "string" then return end
        return v

    end
end

function Cache:internalDecode(v)
    if     self.contentType == "application/json" then
        return json.decode(v)

    elseif self.contentType == "?"                then
        if type(v) ~= "string" then return end
        return v

    end
end

----------------------------------------
-- 索引主键
----------------------------------------

function Cache:internalGetKey(k, ctx)
    return os.md5(string.format("[%s]::%s", ctx, k))
end

function Cache:internalExpired(t)
    local e = os.time() - self.expires

    if t > e then
        return false
    end

    return true
end

return Cache

