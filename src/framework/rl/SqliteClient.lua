
local log = rl.log("SqliteClient")

local lsqlite3 = require("lsqlite3")

local SqliteClient = rl.class("SqliteClient")

function SqliteClient:ctor(filename)
    self.sqlite = lsqlite3.open(filename)
    self.dbfile = filename
end

----------------------------------------
-- 公开函数·基础操作
----------------------------------------

function SqliteClient:exec(sql)
    if DEBUG_LOG_SQL then log.debug(sql) end

    local ret = self.sqlite:exec(sql)

    if self:check() then
        return ret
    end
end

function SqliteClient:rows(sql)
    if DEBUG_LOG_SQL then log.debug(sql) end

    local ret = {}

    for row in self.sqlite:nrows(sql) do
        ret[#ret + 1] = row
    end

    return ret
end

function SqliteClient:pick(sql)
    local ret = self:rows(sql)

    if #ret > 0 then
        return ret[1]
    end
end

function SqliteClient:check()
    if self.sqlite:errcode() == 0 then
        return true
    else
        log.warn("%s - %s", self.sqlite:errcode(), self.sqlite:errmsg())
    end
end

function SqliteClient:lastInsertRowId()
    return self.sqlite:last_insert_rowid()
end

----------------------------------------
-- 公开函数·数据表
----------------------------------------

function SqliteClient:existsTable(tbl_name)
    local rows = self:rows(string.format("SELECT * FROM sqlite_master WHERE type='table' and name='%s'", tbl_name))

    if #rows > 0 then
        return true
    end

    return false
end

function SqliteClient:createTable(tbl_name, tbl_cols)
    local tbl_cols_name = {}

    for i, v in ipairs(tbl_cols) do
        if v[3] then
            tbl_cols_name[i] = string.format("%-20s %-10s %s", v[1], v[2], v[3])
        else
            tbl_cols_name[i] = string.format("%-20s %-10s"   , v[1], v[2])
        end
    end

    local sql = string.format("CREATE TABLE IF NOT EXISTS %s (\n\t%s\n)", tbl_name, table.concat(tbl_cols_name, ",\n\t"))
    self:exec(sql)
end

function SqliteClient:dropTable(tbl_name)
    local sql = string.format("DROP TABLE IF EXISTS %s", tbl_name)
    self:exec(sql)
end

function SqliteClient:dumpTable(tbl_name, opts)
    local opts = opts or {}

    local raws = {}

    if opts.schema then

        local rows = self:rows(string.format("SELECT * FROM sqlite_master WHERE type='table' and name='%s'", tbl_name))

        if #rows > 0 then
            raws[#raws + 1] = string.format("  %-10s  ", string.format("TABLE[%s].SCHEMA", tbl_name))
            raws[#raws + 1] = string.rep("-", 80)
            raws[#raws + 1] = string.format("%s", rows[1].sql)
        end

    end

    if opts.rows   then

        local rows = self:rows(string.format("SELECT * FROM %s", tbl_name))

        if #rows > 0 then
            raws[#raws + 1] = string.format("  %-10s  ", string.format("TABLE[%s].ROWS", tbl_name))
            raws[#raws + 1] = string.rep("-", 80)

            for _, row in ipairs(rows) do
                raws[#raws + 1] = string.format("%s", table.tostring(row))
            end
        end

    end

    local rows = self:rows(string.format("SELECT COUNT(*) AS c FROM %s", tbl_name))

    if #rows > 0 then
        raws[#raws + 1] = string.rep("-", 80)
        raws[#raws + 1] = string.format("%73s rows", rows[1].c)
    end

    log.info("\n%s", table.concat(raws, "\n"))
end

----------------------------------------
-- 公开函数·CRUD
----------------------------------------

function SqliteClient:insert(tbl_name, tbl_cols, obj)
    local tbl_pk_name, tbl_pk_type = self:getPrimaryKey(tbl_cols)
    local tbl_cols_name = {}
    local tbl_cols_val  = {}

    for i, v in ipairs(tbl_cols) do
        local cname = v[1]
        local ctype = v[2]

        if obj[cname] then
            tbl_cols_name[#tbl_cols_name + 1] = cname
            tbl_cols_val[#tbl_cols_val + 1] = self:getSqlVal(ctype, obj[cname])
        end
    end

    local sql = string.format("INSERT INTO %s (%s) VALUES (%s)", tbl_name, table.concat(tbl_cols_name, ", "), table.concat(tbl_cols_val, ", "))
    self:exec(sql)

    if not obj[tbl_pk_name] then
        obj[tbl_pk_name] = self:lastInsertRowId()
    end

    return obj
end

function SqliteClient:update(tbl_name, tbl_cols, obj, col)
    local tbl_pk_name, tbl_pk_type = self:getPrimaryKey(tbl_cols)
    local tbl_pk_val               = self:getSqlVal(tbl_pk_type, obj[tbl_pk_name])

    local tbl_cols_name = {}

    local col = col or {}

    for i, v in ipairs(tbl_cols) do
        local cname = v[1]
        local ctype = v[2]

        if v[3] ~= "PRIMARY KEY" and (obj[cname] or col[cname])then
            tbl_cols_name[#tbl_cols_name + 1] = string.format("%s=%s", cname, self:getSqlVal(ctype, obj[cname]))
        end
    end

    local sql = string.format("UPDATE %s SET %s WHERE %s=%s", tbl_name, table.concat(tbl_cols_name, ", "), tbl_pk_name, tbl_pk_val)
    self:exec(sql)

    return obj
end

function SqliteClient:delete(tbl_name, tbl_cols, id)
    local tbl_pk_name, tbl_pk_type = self:getPrimaryKey(tbl_cols)
    local tbl_pk_val               = self:getSqlVal(tbl_pk_type, id)

    local sql = string.format("DELETE FROM %s WHERE %s=%s", tbl_name, tbl_pk_name, tbl_pk_val)
    self:exec(sql)
end

function SqliteClient:save(tbl_name, tbl_cols, obj)
    local tbl_pk_name, tbl_pk_type = self:getPrimaryKey(tbl_cols)
    local tbl_pk_val               = obj[tbl_pk_name]

    if not self:findById(tbl_name, tbl_cols, tbl_pk_val) then
        return self:insert(tbl_name, tbl_cols, obj)
    else
        return self:update(tbl_name, tbl_cols, obj)
    end
end

function SqliteClient:findById(tbl_name, tbl_cols, id)
    local tbl_pk_name, tbl_pk_type = self:getPrimaryKey(tbl_cols)
    local tbl_pk_val               = self:getSqlVal(tbl_pk_type, id)

    local sql = string.format("SELECT * FROM %s WHERE %s=%s", tbl_name, tbl_pk_name, tbl_pk_val)
    return self:pick(sql)
end

function SqliteClient:findAll(tbl_name)
    local sql = string.format("SELECT * FROM %s WHERE 1=1", tbl_name)
    return self:rows(sql)
end

----------------------------------------
-- 公开函数·辅助方法
----------------------------------------

function SqliteClient:getPrimaryKey(tbl_cols)
    for i, v in ipairs(tbl_cols) do
        if v[3] == "PRIMARY KEY" then
            return v[1], v[2]
        end
    end
end

function SqliteClient:getSqlVal(tbl_col_type, val)
    local ret = "NULL"

    if val then
        if tbl_col_type == "TEXT" then
            ret = string.format("'%s'", val)
        else
            ret = string.format( "%s" , val)
        end
    end

    return ret
end

return SqliteClient

