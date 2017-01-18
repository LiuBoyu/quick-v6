
-- table schema
local tblcols = {
    { "field",      "TEXT",         "PRIMARY KEY" },
    { "value",      "TEXT",                       },
    { "dirty",      "INTEGER",                    },
}

----------------------------------------
-- 组件·数据模型·Sqlite持久化 SqliteModel
----------------------------------------

return function(object, args)

    local component = { id = "SqliteModel" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("SimpleModel") then object:addComponent("SimpleModel", args) end

----------------------------------------
-- 组件参数
----------------------------------------

    local simplemodel = object:getComponent("SimpleModel")
    local simpledata  = object:getall()

    local args = args or {}

    local sqlite = args.sqlite or rl.G.SqliteClient

    local tblname = args.table
    local tblcols = tblcols

    local flushopts = args.flush or {}
    local flushdict = {}

    local dirty = false
    local flag  = {}

    -- check table
    local checktable = function()
        if not sqlite:existsTable(tblname) then
            sqlite:createTable(tblname, tblcols)
        end
    end

    -- sqlite get all
    local getall = function()
        local sql = string.format("SELECT field, value FROM %s", tblname)

        local rows = sqlite:rows(sql)

        if #rows > 0 then
            local tbl = {}
            for _, v in ipairs(rows) do
                if v.value then
                    tbl[v.field] = json.decode(v.value)
                end
            end
            return tbl
        end
    end

    -- init
    local function init()
        -- 检查数据表
        checktable()

        -- 加载数据
        local data = getall() or {}

        -- 初始模型
        simplemodel:init(data)

        -- 加载数据
        simpledata = data
    end

    init()

----------------------------------------
-- 组件方法·默认
----------------------------------------

    function component:init(table)

        if table then
            tblname = table
        end

        init()
    end

----------------------------------------
-- 组件方法·脏数据
----------------------------------------

    function component:checkFlush(field)
        local v = flushdict[field]

        if type(v) == "boolean" then
            if v then
                return true
            end
            return false
        end

        for _, p in ipairs(flushopts) do
            if string.sub(p, -1) == "*" then
                if string.startswith(field, string.sub(p, 1, -2)) then
                    flushdict[field] = true
                    return true
                end
            else
                if field == p then
                    flushdict[field] = true
                    return true
                end
            end
        end

        flushdict[field] = false
        return false
    end

    -- check dirty
    function component:checkDirtyBySimpleModel()
        if dirty then
            return flag
        end
    end

    -- clean dirty
    function component:cleanDirtyBySimpleModel()
        dirty = false
        flag  = {}
    end

    -- check dirty (internal)
    local function checkdirtyBySimpleModel(field, value)
        local v0 = simpledata[field]
        local v1 = value
        local f0 = flag[field]

        if     v0 and     v1 then
            if not f0 then
                flag[field] = "update"
            end
        elseif v0 and not v1 then
            if not f0 then
                flag[field] = "delete"
            else
                if f0 == "insert" then
                    flag[field] = nil
                else
                    flag[field] = "delete"
                end
            end
        elseif v1 and not v0 then
            if not f0 then
                flag[field] = "insert"
            else
                if f0 == "delete" then
                    flag[field] = "update"
                end
            end
        end

        dirty = true
    end

    simplemodel:setOnInit(function(data)
        component:cleanDirtyBySimpleModel()
    end)

    simplemodel:setOnSet(function(field, value)
        if component:checkFlush(field, value) then
            checkdirtyBySimpleModel(field, value)
        end
    end)

----------------------------------------
-- 组件方法·脏数据
----------------------------------------

    function component:checkDirty()
        local sql = string.format("SELECT field, value FROM %s WHERE dirty=1", tblname)

        local rows = sqlite:rows(sql)

        if #rows > 0 then
            local tbl = {}
            for _, v in ipairs(rows) do
                if v.value then
                    tbl[v.field] = json.decode(v.value)
                else
                    tbl[v.field] = json.null
                end
            end
            return tbl
        end
    end

    function component:cleanDirty()
        -- clean dirty
        local sql1 = string.format("UPDATE %s SET dirty=0 WHERE dirty=1", tblname)
        sqlite:exec(sql1)
        -- clean null
        local sql2 = string.format("DELETE FROM %s WHERE value=NULL", tblname)
        sqlite:exec(sql2)
    end

    function component:setupTable(data)
        -- clean table
        local sql = string.format("DELETE FROM %s", tblname)
        sqlite:exec(sql)
        -- setup table
        for k, v in pairs(data) do
            sqlite:insert(tblname, tblcols, { field = k, value = json.encode(v), dirty = 0 })
        end
        -- init
        init()
    end

    function component:alterTable(table)
        -- alter table
        local sql = string.format("ALTER TABLE '%s' RENAME TO '%s'", tblname, table)
        sqlite:exec(sql)
        -- rename table
        tblname = table
    end

----------------------------------------
-- 对象方法·flush
----------------------------------------

    -- sqlite insert
    local insert = function(field, value)
        sqlite:save(tblname, tblcols, { field = field, value = value, dirty = 1 })
    end

    -- sqlite update
    local update = function(field, value)
        sqlite:update(tblname, tblcols, { field = field, value = value, dirty = 1 }, { value = true })
    end

    -- sqlite delete
    local delete = function(field, value)
        sqlite:update(tblname, tblcols, { field = field, value = value, dirty = 1 }, { value = true })
    end

    -- flush
    function object:flush()
        local flag = component:checkDirtyBySimpleModel()

        if not flag then
            return
        end

        local data = self:getall()

        for k, v in pairs(flag) do
            if     v == "update" then
                update(k, json.encode(data[k]))

                if DEBUG_LOG_SQLITEMODEL then
                    self:logDEBUG("刷新: [%s] = %s", k, data[k])
                end

            elseif v == "delete" then
                delete(k, json.encode(data[k]))

                if DEBUG_LOG_SQLITEMODEL then
                    self:logDEBUG("刷新: [%s] (-)= %s", k, data[k])
                end

            elseif v == "insert" then
                insert(k, json.encode(data[k]))

                if DEBUG_LOG_SQLITEMODEL then
                    self:logDEBUG("刷新: [%s] (+)= %s", k, data[k])
                end

            end
        end

        component:cleanDirtyBySimpleModel()
    end

    return component
end

